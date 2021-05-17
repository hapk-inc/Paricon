import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/newNameProvider.dart';
import 'providers/pageProvider.dart';
import 'selectAuth.dart';

class EnterName extends StatelessWidget {
  final _controller = TextEditingController();

  static MaterialPage get toMaterialPage => MaterialPage(
        child: EnterName(),
        key: ValueKey('enterName'),
        name: '/enterName',
      );
  @override
  Widget build(BuildContext context) {
    _onSubmitted() {
      if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
      if (_controller.text.isNotEmpty)
        context
          ..read(newNameNotifier.notifier).state = capsFirst(_controller.text)
          ..read(pageProvider).addNext(SelectAuth.toMaterialPage);
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please Enter your Name',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32.0),
          child: TextField(
            controller: _controller,
            cursorHeight: 40,
            cursorColor: Colors.white70,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontSize: 24, letterSpacing: 2),
            onEditingComplete: () => _onSubmitted(),
            decoration: InputDecoration(
              hintText: "Enter Name",
              filled: true,
              fillColor: Colors.indigo[600],
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white60, width: 4),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white70,
                ),
                onPressed: _onSubmitted,
              ),
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(fontSize: 24, color: Colors.white24),
              contentPadding: const EdgeInsets.all(20.0),
            ),
          ),
        ),
      ),
    );
  }

  String capsFirst(String text) =>
      text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
}
