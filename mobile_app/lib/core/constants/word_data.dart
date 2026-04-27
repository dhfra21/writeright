/// Level 2 word list with emoji picture clues.
/// Words are grouped by difficulty (2-letter → 3-letter → 4-letter).
class WordData {
  static const List<WordEntry> all = [
    // ── 2-letter words ──
    WordEntry(word: 'UP', emoji: '⬆️', hint: 'the opposite of down'),
    WordEntry(word: 'GO', emoji: '🚦', hint: 'move forward'),
    WordEntry(word: 'IN', emoji: '📥', hint: 'inside something'),
    WordEntry(word: 'ON', emoji: '💡', hint: 'the light is on'),
    WordEntry(word: 'IT', emoji: '👆', hint: 'that thing'),
    WordEntry(word: 'AT', emoji: '📍', hint: 'a location'),

    // ── 3-letter words ──
    WordEntry(word: 'CAT', emoji: '🐱', hint: 'a furry pet that meows'),
    WordEntry(word: 'DOG', emoji: '🐶', hint: 'a pet that barks'),
    WordEntry(word: 'SUN', emoji: '☀️', hint: 'it shines in the sky'),
    WordEntry(word: 'HAT', emoji: '🎩', hint: 'you wear it on your head'),
    WordEntry(word: 'CUP', emoji: '☕', hint: 'you drink from it'),
    WordEntry(word: 'BUS', emoji: '🚌', hint: 'a big yellow vehicle'),
    WordEntry(word: 'PIG', emoji: '🐷', hint: 'a pink farm animal'),
    WordEntry(word: 'HEN', emoji: '🐔', hint: 'a female chicken'),
    WordEntry(word: 'ANT', emoji: '🐜', hint: 'a tiny insect'),
    WordEntry(word: 'BEE', emoji: '🐝', hint: 'it makes honey'),
    WordEntry(word: 'FOX', emoji: '🦊', hint: 'an orange wild animal'),
    WordEntry(word: 'COW', emoji: '🐮', hint: 'it gives us milk'),

    // ── 4-letter words ──
    WordEntry(word: 'FROG', emoji: '🐸', hint: 'it jumps and says ribbit'),
    WordEntry(word: 'DUCK', emoji: '🦆', hint: 'it swims and quacks'),
    WordEntry(word: 'FISH', emoji: '🐟', hint: 'it lives in water'),
    WordEntry(word: 'BEAR', emoji: '🐻', hint: 'a big furry animal'),
    WordEntry(word: 'BIRD', emoji: '🐦', hint: 'it flies in the sky'),
    WordEntry(word: 'CAKE', emoji: '🎂', hint: 'a sweet birthday treat'),
    WordEntry(word: 'STAR', emoji: '⭐', hint: 'it shines at night'),
    WordEntry(word: 'TREE', emoji: '🌳', hint: 'it has leaves and branches'),
  ];
}

class WordEntry {
  final String word;
  final String emoji;
  final String hint;

  const WordEntry({
    required this.word,
    required this.emoji,
    required this.hint,
  });
}
