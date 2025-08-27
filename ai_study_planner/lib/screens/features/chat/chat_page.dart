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
      'chatOwnerID':
          firebaseAuth.currentUser!.uid, // 👈 separates chats per user
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where(
                    'chatOwnerID',
                    isEqualTo: firebaseAuth.currentUser!.uid,
                  )
                  .where('receiverID', isEqualTo: widget.receiverUserID)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe =
                        message['senderID'] == firebaseAuth.currentUser!.uid;

                    return ChatBubble(
                      message: message['message'] ?? '',
                      bubbleColor: isMe ? Colors.deepOrangeAccent : Colors.pink,
                      fontColor: isMe ? Colors.black87 : Colors.white,
                      alignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: pickDocument,
                  icon: Icon(Icons.attach_file),
                  tooltip: 'Upload PDF',
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(Icons.send),
                  tooltip: 'Send',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
