/// Level 2 word list with emoji picture clues.
/// Words are grouped by difficulty (2-letter → 3-letter → 4-letter).
/// Each entry also includes a fill-in-the-blank sentence for Level 3.
class WordData {
  static const List<WordEntry> all = [
    // ── 2-letter words ──
    WordEntry(
      word: 'UP',
      emoji: '⬆️',
      hint: 'the opposite of down',
      sentence: 'The balloon floats ___',
    ),
    WordEntry(
      word: 'GO',
      emoji: '🚦',
      hint: 'move forward',
      sentence: 'Ready, set, ___!',
    ),
    WordEntry(
      word: 'IN',
      emoji: '📥',
      hint: 'inside something',
      sentence: 'The cat is ___ the box',
    ),
    WordEntry(
      word: 'ON',
      emoji: '💡',
      hint: 'the light is on',
      sentence: 'Please turn ___ the light',
    ),
    WordEntry(
      word: 'IT',
      emoji: '👆',
      hint: 'that thing',
      sentence: '___ is a sunny day',
    ),
    WordEntry(
      word: 'AT',
      emoji: '📍',
      hint: 'a location',
      sentence: 'She is ___ the park',
    ),

    // ── 3-letter words ──
    WordEntry(
      word: 'CAT',
      emoji: '🐱',
      hint: 'a furry pet that meows',
      sentence: 'The ___ drinks warm milk',
    ),
    WordEntry(
      word: 'DOG',
      emoji: '🐶',
      hint: 'a pet that barks',
      sentence: 'The ___ wags its tail',
    ),
    WordEntry(
      word: 'SUN',
      emoji: '☀️',
      hint: 'it shines in the sky',
      sentence: 'The ___ is very bright',
    ),
    WordEntry(
      word: 'HAT',
      emoji: '🎩',
      hint: 'you wear it on your head',
      sentence: 'She wore a big red ___',
    ),
    WordEntry(
      word: 'CUP',
      emoji: '☕',
      hint: 'you drink from it',
      sentence: 'I filled my ___ with juice',
    ),
    WordEntry(
      word: 'BUS',
      emoji: '🚌',
      hint: 'a big yellow vehicle',
      sentence: 'We ride the ___ to school',
    ),
    WordEntry(
      word: 'PIG',
      emoji: '🐷',
      hint: 'a pink farm animal',
      sentence: 'The ___ rolled in the mud',
    ),
    WordEntry(
      word: 'HEN',
      emoji: '🐔',
      hint: 'a female chicken',
      sentence: 'The ___ laid three eggs',
    ),
    WordEntry(
      word: 'ANT',
      emoji: '🐜',
      hint: 'a tiny insect',
      sentence: 'A tiny ___ carried a crumb',
    ),
    WordEntry(
      word: 'BEE',
      emoji: '🐝',
      hint: 'it makes honey',
      sentence: 'The ___ landed on a flower',
    ),
    WordEntry(
      word: 'FOX',
      emoji: '🦊',
      hint: 'an orange wild animal',
      sentence: 'The ___ ran into the forest',
    ),
    WordEntry(
      word: 'COW',
      emoji: '🐮',
      hint: 'it gives us milk',
      sentence: 'The ___ lives on the farm',
    ),

    // ── 4-letter words ──
    WordEntry(
      word: 'FROG',
      emoji: '🐸',
      hint: 'it jumps and says ribbit',
      sentence: 'The ___ jumped over the log',
    ),
    WordEntry(
      word: 'DUCK',
      emoji: '🦆',
      hint: 'it swims and quacks',
      sentence: 'The ___ swam in the pond',
    ),
    WordEntry(
      word: 'FISH',
      emoji: '🐟',
      hint: 'it lives in water',
      sentence: 'The ___ swam under the boat',
    ),
    WordEntry(
      word: 'BEAR',
      emoji: '🐻',
      hint: 'a big furry animal',
      sentence: 'The ___ slept all winter',
    ),
    WordEntry(
      word: 'BIRD',
      emoji: '🐦',
      hint: 'it flies in the sky',
      sentence: 'A little ___ sat on the branch',
    ),
    WordEntry(
      word: 'CAKE',
      emoji: '🎂',
      hint: 'a sweet birthday treat',
      sentence: 'We sang and ate the ___',
    ),
    WordEntry(
      word: 'STAR',
      emoji: '⭐',
      hint: 'it shines at night',
      sentence: 'I saw a bright ___ in the sky',
    ),
    WordEntry(
      word: 'TREE',
      emoji: '🌳',
      hint: 'it has leaves and branches',
      sentence: 'The bird built a nest in the ___',
    ),
  ];
}

class WordEntry {
  final String word;
  final String emoji;
  final String hint;
  final String sentence;

  const WordEntry({
    required this.word,
    required this.emoji,
    required this.hint,
    required this.sentence,
  });
}