import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared buddy (avatar) definitions used across the app.
class BuddyData {
  final String emoji;
  final String name;
  final Color color;
  final String greeting;    // used on account creation screen
  final String idleMessage; // shown in practice before the child draws

  const BuddyData({
    required this.emoji,
    required this.name,
    required this.color,
    required this.greeting,
    required this.idleMessage,
  });

  static const List<BuddyData> all = [
    BuddyData(
      emoji: '\uD83E\uDD81',
      name: 'Lion',
      color: AppTheme.primaryOrange,
      greeting: "Roar! I'm Lion! I'll help you write like a champion! \uD83D\uDCAA",
      idleMessage: "Let's write it together! You've got this! \uD83D\uDCAA",
    ),
    BuddyData(
      emoji: '\uD83D\uDC3B',
      name: 'Bear',
      color: AppTheme.accentPink,
      greeting: "Hey there! I'm Bear! Writing with you will be so much fun! \uD83D\uDC3E",
      idleMessage: "Take your time and draw your best! I believe in you! \uD83C\uDF1F",
    ),
    BuddyData(
      emoji: '\uD83D\uDC30',
      name: 'Bunny',
      color: AppTheme.primaryPurple,
      greeting: "Hi hi! I'm Bunny! Let's hop through every letter together! \uD83E\uDD55",
      idleMessage: "Hop to it! Draw the letter and show me what you've got! \uD83D\uDC30",
    ),
    BuddyData(
      emoji: '\uD83E\uDD8A',
      name: 'Fox',
      color: AppTheme.accentGreen,
      greeting: "Hey smarty! I'm Fox! We're going to be the best writers ever! \uD83C\uDF1F",
      idleMessage: "Use that clever brain and write it perfectly! \uD83E\uDD8A",
    ),
    BuddyData(
      emoji: '\uD83D\uDC27',
      name: 'Penguin',
      color: AppTheme.accentBlue,
      greeting: "Waddle! I'm Penguin! Let's slide through every letter! \u2744\uFE0F",
      idleMessage: "Slide your pencil and write a great letter! \u2744\uFE0F",
    ),
    BuddyData(
      emoji: '\uD83E\uDD84',
      name: 'Unicorn',
      color: AppTheme.accentYellow,
      greeting: "Hi! I'm Unicorn! Writing is pure magic with me! \u2728",
      idleMessage: "Sprinkle some magic and write a beautiful letter! \u2728",
    ),
  ];
}
