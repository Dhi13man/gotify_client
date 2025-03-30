import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Send'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      ],
      onTap: onTap,
    );
  }
}
