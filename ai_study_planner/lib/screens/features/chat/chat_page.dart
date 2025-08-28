import 'dart:io';
import 'package:ai_study_planner/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../components/widgets/chat_bubble.dart';
import 'chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController messageController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final ChatServices api = ChatServices();
  final ScrollController _scrollController = ScrollController();

  File? selectedFile;
  String? selectedFileName;
  bool fileUploaded = false;
  bool isUploading = false;
  bool isTyping = false;
  late AnimationController _typingController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Send welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendWelcomeMessage();
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _sendWelcomeMessage() async {
    await _sendToFirebase(
      '👋 Hello! I\'m your AI Study Assistant. How can I help you today?',
      senderType: 'ai',
    );
  }

  void sendMessage() async {
    if (messageController.text.isEmpty) return;

    final question = messageController.text;
    await _sendToFirebase(question, senderType: 'human');
    messageController.clear();

    // Show typing indicator
    setState(() {
      isTyping = true;
    });

    // Get AI response
    final aiReply = await api.askQuestion(question);
    if (aiReply != null) {
      await _sendToFirebase(aiReply, senderType: 'ai');
    }

    setState(() {
      isTyping = false;
    });

    _scrollToBottom();
  }

  Future<void> _sendToFirebase(
    String message, {
    String senderType = 'human',
  }) async {
    await FirebaseFirestore.instance.collection('messages').add({
      'chatOwnerID': firebaseAuth.currentUser!.uid,
      'senderID': senderType == 'human'
          ? firebaseAuth.currentUser!.uid
          : 'ai_bot',
      'receiverID': widget.receiverUserID,
      'message': message,
      'timestamp': Timestamp.now(),
      'senderType': senderType,
    });
  }

  Future<void> _clearChatHistory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Clear Chat History'),
            ],
          ),
          content: Text(
            'Are you sure you want to clear all chat messages? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performClearChat();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Clear All',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performClearChat() async {
    try {
      // Get all messages for this user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('chatOwnerID', isEqualTo: firebaseAuth.currentUser!.uid)
          .get();

      // Delete all messages
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Send a new welcome message
      await _sendWelcomeMessage();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Chat history cleared successfully!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing chat history: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      setState(() {
        selectedFile = file;
        selectedFileName = fileName;
        fileUploaded = false;
        isUploading = true;
      });

      final summary = await api.uploadFile(file);

      if (summary != null) {
        setState(() {
          fileUploaded = true;
          isUploading = false;
        });

        await _sendToFirebase(
          '📎 File "$fileName" uploaded.',
          senderType: 'human',
        );
        await _sendToFirebase(summary, senderType: 'ai');
      } else {
        setState(() => isUploading = false);
        await _sendToFirebase("[File upload failed]", senderType: 'ai');
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back, color: Colors.grey[700]),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.purple[400]!],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Study Assistant',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your Personal Learning Buddy',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _clearChatHistory,
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete_sweep, color: Colors.red[400], size: 20),
            ),
            tooltip: 'Clear Chat History',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Welcome Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.purple[50]!],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Study Tips & Help',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Ask me about study techniques, motivation, time management, focus strategies, and more!',
                  style: TextStyle(fontSize: 13, color: Colors.blue[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where(
                    'chatOwnerID',
                    isEqualTo: firebaseAuth.currentUser!.uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading messages',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[400]!,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading chat...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                // Filter and sort messages locally
                final filteredMessages = messages.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['receiverID'] == widget.receiverUserID;
                }).toList();

                filteredMessages.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTimestamp = aData['timestamp'] as Timestamp?;
                  final bTimestamp = bData['timestamp'] as Timestamp?;

                  if (aTimestamp == null && bTimestamp == null) return 0;
                  if (aTimestamp == null) return 1;
                  if (bTimestamp == null) return -1;

                  return bTimestamp.compareTo(aTimestamp);
                });

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: filteredMessages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredMessages.length && isTyping) {
                      return _buildTypingIndicator();
                    }

                    final message =
                        filteredMessages[index].data() as Map<String, dynamic>;
                    final isMe =
                        message['senderID'] == firebaseAuth.currentUser!.uid;

                    return ChatBubble(
                      message: message['message'] ?? '',
                      bubbleColor: isMe ? Colors.blue[600]! : Colors.white,
                      fontColor: isMe ? Colors.white : Colors.black87,
                      alignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                    );
                  },
                );
              },
            ),
          ),

          // File Upload Status
          if (isUploading)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border(
                  top: BorderSide(color: Colors.orange[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange[600]!,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Processing file...',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // File Upload Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: pickDocument,
                    icon: Icon(Icons.attach_file, color: Colors.blue[600]),
                    tooltip: 'Upload Study Material',
                  ),
                ),

                SizedBox(width: 12),

                // Message Input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about studying...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      onSubmitted: (_) => sendMessage(),
                      maxLines: null,
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Send Button
                GestureDetector(
                  onTap: sendMessage,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[600]!, Colors.purple[600]!],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(
                                0.3 + _pulseController.value * 0.2,
                              ),
                              blurRadius: 8 + _pulseController.value * 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.send, color: Colors.white, size: 20),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_buildDot(0), _buildDot(1), _buildDot(2)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = (_typingController.value + delay) % 1.0;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.blue[400]!.withOpacity(0.5 + animationValue * 0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
