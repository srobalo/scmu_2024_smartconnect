import 'dart:math';

String generateExcuse() {
  final intro = [
    "Sorry I can't come,",
    "Please forgive my absence,",
    "This is going to sound crazy but",
    "Get this:",
    "I can't go because",
    "I know you're going to hate me but",
    "I was minding my own business and",
    "I feel terrible but",
    "I regretfully cannot attend,",
    "This is going to sound like an excuse but",
    "I didn't expect this to happen but",
    "It's unbelievable but",
    "I swear I'm not making this up but",
    "I couldn't believe it myself but",
    "I'm really sorry but",
    "I never thought this would happen but",
    "I'm embarrassed to say but",
    "I'm in shock but",
    "I couldn't make this up if I tried but",
    "I know you won't believe me but",
  ];

  final scapegoat = [
    "my nephew",
    "the ghost of Hitler",
    "the Pope",
    "my ex",
    "a high school marching band",
    "Dan Rather",
    "a sad clown",
    "the kid from Air Bud",
    "a professional cricket team",
    "my Tinder date",
    "a group of aliens",
    "a talking dolphin",
    "a time-traveling unicorn",
    "a troupe of dancing penguins",
    "a colony of ants",
    "a psychic banana",
    "a mischievous leprechaun",
    "a sentient robot",
    "a pack of wild llamas",
    "a magical talking tree",
  ];

  final delay = [
    "just shat my bed",
    "died in front of me",
    "won't stop telling me knock knock jokes",
    "is having a nervous breakdown",
    "gave me syphilis",
    "poured lemonade in my gas tank",
    "stabbed me",
    "found my box of human teeth",
    "stole my bicycle",
    "posted my nudes on Instagram",
    "filled my house with balloons",
    "sent me on a wild goose chase",
    "hid my car keys",
    "ate my homework",
    "started a rumor about me",
    "hid my phone charger",
    "ate all the cookies",
    "pranked me with fake lottery tickets",
    "replaced my shampoo with mayonnaise",
    "locked me out of my own house",
  ];


  final random = Random.secure();

  final introIndex = random.nextInt(intro.length);
  final scapegoatIndex = random.nextInt(scapegoat.length);
  final delayIndex = random.nextInt(delay.length);

  final excuse = '${intro[introIndex]} ${scapegoat[scapegoatIndex]} ${delay[delayIndex]}.';
  return excuse;
}