// ignore_for_file: prefer_const_constructors

import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_gpt_bot/Components/colors.dart';
import 'package:chat_gpt_bot/Models/api_sevices.dart';
import 'package:chat_gpt_bot/Models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  var text = "Hold the Button and start speaking";
  SpeechToText speechToText = SpeechToText();
  var isListening = false;
  final List<ChatMessage> messages = [];
  var scrollController = ScrollController();

  scrollMethod() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Voice GPT",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 75,
        animate: isListening,
        duration: Duration(seconds: 2),
        glowColor: bgColor,
        repeatPauseDuration: Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) async {
            if (!isListening) {
              var available = await speechToText.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  speechToText.listen(
                    onResult: (result) {
                      setState(() {
                        text = result.recognizedWords;
                      });
                    },
                  );
                });
              }
            }
          },
          onTapUp: (details) async {
            setState(() {
              isListening = false;
            });
            speechToText.stop();
            messages.add(ChatMessage(text: text, type: ChatMessageType.user));
            var msg = await ApiServices.sendMessage(text);

            setState(() {
              messages.add(ChatMessage(text: msg, type: ChatMessageType.bot));
            });
          },
          child: CircleAvatar(
            backgroundColor: bgColor,
            radius: 35,
            child: isListening ? Icon(Icons.mic) : Icon(Icons.mic_none),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: EdgeInsets.only(bottom: 5),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                color: isListening ? Colors.black : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Expanded(
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: chatBgColor,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: scrollController,
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      var chat = messages[index];
                      return chatBubble(chatText: chat.text, type: chat.type);
                    },
                  )),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "Developed by Krishna",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatBubble({required chatText, required ChatMessageType? type}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: bgColor,
          child: Icon(Icons.person, color: Colors.white),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(17),
                    bottomRight: Radius.circular(17),
                    topRight: Radius.circular(17))),
            child: Text(
              chatText,
              style: TextStyle(
                color: chatBgColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
