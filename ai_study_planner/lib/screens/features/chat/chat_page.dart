import 'dart:io';
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

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final ChatServices api = ChatServices();
  final ScrollController _scrollController = ScrollController();

  File? selectedFile;
  String? selectedFileName;
  bool fileUploaded = false;
  bool isUploading = false;

  void sendMessage() async {
    if (messageController.text.isEmpty) return;

    final question = messageController.text;
    await _sendToFirebase(question, senderType: 'human');
    messageController.clear();

    if (fileUploaded) {
      final aiReply = await api.askQuestion(question);
      if (aiReply != null) {
        await _sendToFirebase(aiReply, senderType: 'ai');
      }
    }
  }

  Future<void> _sendToFirebase(
    String message, {
    String senderType = 'human',
  }) async {
    await FirebaseFirestore.instance.collection('messages').add({
      'senderID': senderType == 'human'
          ? firebaseAuth.currentUser!.uid
          : 'ai_bot',
      'receiverID': widget.receiverUserID,
      'message': message,
      'timestamp': Timestamp.now(),
      'senderType': senderType,
    });
  }

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
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
        await _sendToFirebase("[AI Summary]: $summary", senderType: 'ai');
      } else {
        setState(() => isUploading = false);
        await _sendToFirebase("[Document Upload Failed]", senderType: 'ai');
      }
    }
  }

  void resetToUploadMode() async {
    await api.resetSession();
    setState(() {
      fileUploaded = false;
      selectedFile = null;
      selectedFileName = null;
      isUploading = false;
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ask Studybot',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
        ),
      ),
      backgroundColor: Color(0xFFF6EAD8), // keep original background
      body: Column(
        children: [
          Expanded(child: buildMessageList()),
          buildMessageInput(),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snapshot.data!.docs;

        final filteredDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final senderID = data['senderID'] as String? ?? '';
          final receiverID = data['receiverID'] as String? ?? '';
          final currentUserID = firebaseAuth.currentUser!.uid;

          final participants = [currentUserID, widget.receiverUserID, 'ai_bot'];
          return participants.contains(senderID) &&
              participants.contains(receiverID);
        }).toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            return buildMessageItem(filteredDocs[index]);
          },
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isUser = data['senderID'] == firebaseAuth.currentUser!.uid;

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ChatBubble(
        message: data['message'],
        bubbleColor: isUser ? Colors.deepOrangeAccent : Colors.pink,
        fontColor: isUser ? Colors.black87 : Colors.white,
        alignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      ),
    );
  }

  Widget buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: fileUploaded
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask a question about the file...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: resetToUploadMode,
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: isUploading ? null : pickDocument,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isUploading
                        ? Row(
                            children: [
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Uploading...",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          )
                        : Text(
                            "Upload a file to begin...",
                            style: TextStyle(color: Colors.black54),
                          ),
                    Icon(Icons.attach_file),
                  ],
                ),
              ),
            ),
    );
  }
}
