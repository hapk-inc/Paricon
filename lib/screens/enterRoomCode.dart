import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paricon/providers/pageProvider.dart';
import 'package:paricon/providers/roomNotifierProvider.dart';
import 'package:paricon/providers/roomProvider.dart';

import 'gameRoom.dart';

class EnterRoomCode extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    SnackBar showErrorSnack(dynamic error) => SnackBar(
          content: Text(
            error,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white70),
          ),
          backgroundColor: Colors.indigo[900],
        );

    void _onPressed() async {
      if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
      if (_controller.text.isNotEmpty && _controller.text.length == 6) {
        //context.read(loadingNotifierProvider.notifier).state = true;
        context.read(roomNotifierProvider).loading = true;
        await context.read(roomCheckProvider(_controller.text).future).then(
          (value) async {
            if (value != null) {
              print("Room created $value");
              await context.read(joinRoomProvider.future);
              context
                  .read(pageProvider)
                  .addNext(GameRoom.toMaterialPage(id: value));
            }
          },
          onError: (err) {
            //context.read(loadingNotifierProvider.notifier).state = false;
            ScaffoldMessenger.of(context).showSnackBar(showErrorSnack(err));
            print("Error coming $err");
          },
        );
        /*.whenComplete(
            () => context.read(loadingNotifierProvider.notifier).state = false);*/
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(showErrorSnack("Enter a Valid Room Code"));
      }
      context.read(roomNotifierProvider).loading = false;
      //context.read(loadingNotifierProvider.notifier).state = false;
    }

    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 4,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(32.0),
                child: TextFormField(
                  controller: _controller,
                  /*validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },*/
                  cursorHeight: 40,
                  cursorColor: Colors.white70,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 36,
                        letterSpacing: 10,
                        fontWeight: FontWeight.w500,
                      ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white54,
                        width: 4,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.indigo[600],
                    hintText: "Enter Room Code",
                    hintStyle: TextStyle(
                        fontSize: 20, letterSpacing: 1, color: Colors.white54),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white70,
                        size: 32,
                      ),
                      splashRadius: 1000,
                      splashColor: Colors.indigo[700],
                      highlightColor: Colors.indigo,
                      onPressed: _onPressed,
                    ),
                  ),
                  onEditingComplete: _onPressed,
                ),
              ),
            ),
            Flexible(
              child: Consumer(
                builder: (context, watch, child) => AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: watch(roomNotifierProvider).loading ? 1 : 0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
