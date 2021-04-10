import 'main.dart';
import 'dnd.dart';
import 'dart:math';

List<int> stats = []; // generated stat values
List<int> bonuses = []; // bonuses that can be changed by user

final List<String> statNames = ['Str', 'Dex', 'Con', 'Int', 'Wis', 'Cha'];
List<List<int>> arrays = [
  [18, 17, 8, 8, 7, 7],
  [18, 15, 14, 7, 7, 7],
  [18, 14, 13, 11, 7, 7],
  [18, 11, 11, 11, 11, 11],
  [17, 16, 10, 10, 9, 9],
  [17, 14, 12, 10, 10, 10],
  [16, 16, 16, 7, 7, 7],
  [16, 15, 14, 10, 8, 8],
  [16, 14, 13, 12, 10, 9],
  [16, 12, 12, 12, 12, 12],
  [15, 14, 14, 14, 9, 9],
  [15, 15, 15, 10, 10, 10],
  [15, 14, 12, 12, 12, 12],
  [14, 14, 14, 14, 14, 9]
];

void generate(index) {
  switch (index) {
    case 0: // 4d6 Drop Lowest
      {
        stats = [];
        for (int i = 0; i < 6; i++) {
          List<int> dice = [];
          for (int j = 0; j < 4; j++) {
            dice.add(d6());
          }
          dice.sort();
          dice.removeAt(0); // drop lowest
          stats.add(dice.reduce((a, b) => a + b)); // append each stat to list
        }
      }
      break;
    case 1: // Standard Array
      {
        stats = [15, 14, 13, 12, 10, 8];
        stats.shuffle();
      }
      break;
    case 2: // Random Array
      {
        stats = pickRandom(arrays).toList();
        stats.shuffle();
      }
      break;
  }

  bonuses = [0, 0, 0, 0, 0, 0];

  if (autoArrange) {
    stats.sort();
    List<int> betterStats = []; // randomly select 3 stats to prioritize
    if (rng.nextInt(13) == 0) {
      betterStats = [0, 1, 2]; // Barbarian
    } else {
      int strDex = (rng.nextDouble() + .75).toInt();
      final int con = 2;
      double x = rng.nextDouble();
      int intWisCha = x < 2 / 9
          ? 3
          : x < 2 / 3
              ? 4
              : 5;
      betterStats = [strDex, con, intWisCha];
      List<int> betterValues = [stats[3], stats[4], stats[5]];
      // betterValues = highest 3 stats
      stats = [stats[0], stats[1], stats[2]];
      // remove betterValues from stats
      stats.shuffle();
      betterValues.shuffle();
      for (final stat in betterStats) {
        // loop through indices of prioritized stats
        stats.insert(stat, betterValues.removeAt(0));
      }
    }
    int highestEvenScore =
        stats.reduce((a, b) => a % 2 != 0 || (b > a && b % 2 == 0) ? b : a);
    int highestOddScore =
        stats.reduce((a, b) => a % 2 == 0 || (b > a && b % 2 != 0) ? b : a);
    bonuses[stats.indexOf(highestEvenScore)] = 2;
    bonuses[stats.indexOf(highestOddScore)] = 1;
  }
}

List<String> getHighestStats() {
  if (stats.length < 6 || bonuses.length < 6) {
    print("stat or bonus array is incomplete");
    return [];
  }
  List<int> statTotals = [0, 0, 0, 0, 0, 0];
  for (int i = 0; i < statTotals.length; i++) {
    statTotals[i] = stats[i] + bonuses[i];
  }
  List<String> bestScores = [];
  List<String> scores2pickfrom = [];
  while (bestScores.length < 6) {
    int maxScore = statTotals.reduce(max);
    for (int i = 0; i < statTotals.length; i++) {
      if (statTotals[i] == maxScore) {
        scores2pickfrom.add(statNames[i]);
      }
    }
    String scoreName = pickRandom(scores2pickfrom);
    bestScores.add(scoreName);
    statTotals[statNames.indexOf(scoreName)] = 0;
    scores2pickfrom = [];
  }
  return bestScores;
}

List<String> getRecommendations() {
  final List<String> bestScores = getHighestStats();
  for (int i = 2; i < bestScores.length; i++) {
    if (stats[statNames.indexOf(bestScores[i])] < 12) bestScores[i] = "";
  }
  List<String> r = []; // list of recommendations
  switch (bestScores[0]) {
    case 'Str': // highest ability is Strength
      {
        switch (bestScores[1]) {
          case 'Dex': // highest abilities: Str, Dex
            {
              r.add('Barbarian');
              break;
            }
          case 'Con': // highest abilities: Str, Con
            {
              r.add('Barbarian');
              switch (bestScores[2]) {
                case 'Int': // Str, Con, Int
                  {
                    r.add('Fighter (${pickRandom([
                      'Eldritch Knight',
                      'Psi Warrior'
                    ])})');
                    break;
                  }
                case 'Wis': // Str, Con, Wis
                  {
                    r.addAll([
                      'Cleric (${pickRandom([
                        'Forge',
                        'Tempest',
                        'Twilight',
                        'War'
                      ])})',
                      'Ranger',
                      'Fighter (Samurai)',
                    ]);
                    break;
                  }
                case 'Cha': // Str, Con, Cha
                  {
                    r.add('Paladin');
                    break;
                  }
              }
              break;
            }
          case 'Int': // highest abilities: Str, Int
            {
              r.add('Fighter (${pickRandom([
                'Eldritch Knight',
                'Psi Warrior',
              ])})');
              break;
            }
          case 'Wis': // highest abilities: Str, Wis
            {
              r.addAll([
                'Cleric (${pickRandom([
                  'Forge',
                  'Tempest',
                  'Twilight',
                  'War'
                ])})',
                'Ranger',
                'Fighter (Samurai)',
              ]);
              break;
            }
          case 'Cha': // highest abilities: Str, Cha
            {
              r.add('Paladin');
              break;
            }
        }
        break;
      }
    case 'Dex': // highest ability is Dexterity
      {
        switch (bestScores[1]) {
          case 'Str': // highest abilities: Dex, Str
            {
              r.add('Barbarian');
              break;
            }
          case 'Con': // highest abilities: Dex, Con
            {
              r.addAll(['Fighter (Archery fighting style)']);
              if (bestScores[2] == 'Wis') // Dex, Con, Wis
                r.addAll(['Rogue (Inquisitive)', 'Ranger']);
              else {
                r.add('Rogue');
                if (bestScores[2] == 'Str') // Dex, Con, Str
                  r.add('Barbarian');
                else if (bestScores[2] == 'Cha') // Dex, Con, Cha
                  r.add('Bard');
              }
              break;
            }
          case 'Int': // highest abilities: Dex, Int
            {
              r.addAll(['Rogue (Arcane Trickster)', 'Wizard (Bladesinger)']);
              break;
            }
          case 'Wis': // highest abilities: Dex, Wis
            {
              r.addAll(['Monk', 'Ranger']);
              break;
            }
          case 'Cha': // highest abilities: Dex, Cha
            {
              r.addAll(['Bard', 'Warlock', 'Rogue (Swashbuckler)']);
              break;
            }
        }
        break;
      }
    case 'Con': // highest ability is Constitution
      {
        switch (bestScores[1]) {
          case 'Str': // highest abilities: Con, Str
            {
              r.addAll(['Barbarian', 'Fighter (Great Weapon fighting style)']);
              switch (bestScores[2]) {
                case 'Wis':
                  {
                    r.addAll([
                      'Cleric (${pickRandom([
                        'Forge',
                        'Tempest',
                        'Twilight',
                        'War'
                      ])})',
                      'Fighter (Samurai)',
                    ]);
                    break;
                  }
                case 'Cha':
                  {
                    r.add('Paladin');
                    break;
                  }
              }
              break;
            }
          case 'Dex': // highest abilities: Con, Dex
            {
              r.addAll(['Fighter (Archery fighting style)', 'Rogue']);
              switch (bestScores[2]) {
                case 'Int':
                  {
                    r.addAll(['Wizard', 'Artificer']);
                    break;
                  }
                case 'Wis':
                  {
                    r.add('Ranger');
                    break;
                  }
                case 'Cha':
                  {
                    r.addAll(['Warlock', 'Bard', 'Sorcerer']);
                    break;
                  }
              }
              break;
            }
          case 'Int': // highest abilities: Con, Int
            {
              r.addAll(['Wizard', 'Artificer']);
              break;
            }
          case 'Wis': // highest abilities: Con, Wis
            {
              r.addAll(['Druid', 'Ranger']);
              if (bestScores[2] == 'Dex') r.add('Monk');
              break;
            }
          case 'Cha': // highest abilities: Con, Cha
            {
              r.addAll(['Sorcerer', 'Warlock', 'Bard']);
              break;
            }
        }
        break;
      }
    case 'Int': // highest ability is Intelligence
      {
        switch (bestScores[1]) {
          case 'Str': // highest abilities: Int, Str
            {
              r.addAll([
                'Fighter (${pickRandom(['Eldritch Knight', 'Psi Warrior'])})',
                pickRandom([
                  'Wizard (School of War, with a couple Fighter levels)',
                  'Wizard (Dwarf [Mark of Warding], School of Abjuration '
                      'with a couple Fighter levels)',
                ]),
              ]);
              break;
            }
          case 'Dex': // highest abilities: Int, Dex
            {
              r.addAll(['Wizard', 'Artificer', 'Rogue (Arcane Trickster)']);
              break;
            }
          case 'Con': // highest abilities: Int, Con
            {
              r.addAll(
                  ['Wizard', 'Artificer', 'Wizard (with one Artificer level)']);
              break;
            }
          case 'Wis': // highest abilities: Int, Wis
            {
              r.add('Wizard (Dwarf, with one ${pickRandom([
                'Forge',
                'Life',
                'Order',
                'Tempest',
                'Twilight',
              ])} Cleric level)');
              break;
            }
          case 'Cha': // highest abilities: Int, Cha
            {
              if (bestScores[2] == 'Dex') {
                r.add('Rogue (Swashbuckler)');
              }
              r.addAll(['Wizard', 'Bard']);
              break;
            }
        }
        break;
      }
    case 'Wis': // highest ability is Wisdom
      {
        switch (bestScores[1]) {
          case 'Str': // highest abilities: Wis, Str
            {
              r.addAll([
                'Cleric (${pickRandom([
                  'Forge',
                  'Tempest',
                  'Twilight',
                  'War'
                ])})',
                'Ranger',
              ]);
              break;
            }
          case 'Dex': // highest abilities: Wis, Dex
            {
              r.addAll([
                'Cleric (${pickRandom([
                  'Arcana',
                  'Death',
                  'Grave',
                  'Light',
                  'Peace',
                  'Trickery'
                ])})',
                'Ranger',
                'Monk',
                'Druid',
              ]);
              break;
            }
          case 'Con': // highest abilities: Wis, Con
            {
              if (bestScores[2] == 'Str') {
                r.addAll([
                  'Cleric (${pickRandom([
                    'Forge',
                    'Life',
                    'Nature',
                    'Order',
                    'Tempest',
                    'Twilight',
                    'War'
                  ])})',
                  'Ranger (with a couple Fighter levels)',
                ]);
              } else if (bestScores[2] == 'Dex') {
                r.addAll(['Druid', 'Ranger', 'Monk']);
              } else {
                r.addAll([
                  'Cleric (Dwarf, ${pickRandom([
                    'Life',
                    'Nature',
                    'Order',
                  ])} Domain)',
                  'Druid',
                  'Ranger (Druidic Warrior fighting style)',
                ]);
              }
              break;
            }
          case 'Int': // highest abilities: Wis, Int
            {
              r.add('Cleric (Knowledge)');
              break;
            }
          case 'Cha': // highest abilities: Wis, Cha
            {
              r.addAll(['Ranger (Fey Wanderer)', 'Cleric (Order)', 'Bard']);
              break;
            }
        }
        break;
      }
    case 'Cha': // highest ability is Charisma
      {
        switch (bestScores[1]) {
          case 'Str': // highest abilities: Cha, Str
            {
              r.add('Paladin');
              break;
            }
          case 'Dex': // highest abilities: Cha, Dex
            {
              r.addAll(['Bard', 'Warlock', 'Sorcerer']);
              break;
            }
          case 'Con': // highest abilities: Cha, Con
            {
              r.addAll(['Sorcerer', 'Warlock']);
              if (bestScores[2] == 'Str') // Cha, Con, Str
                r.add('Paladin (with one Hexblade Warlock level)');
              else if (bestScores[2] == 'Dex') // Cha, Con, Dex
                r.add('Bard');
              else
                r.add('Sorcerer (with two Warlock levels)');
              break;
            }
          case 'Int': // highest abilities: Cha, Int
            {
              r.addAll([
                'Bard',
                'Rogue (Swashbuckler, with one Hexblade Warlock level)',
              ]);
              break;
            }
          case 'Wis': // highest abilities: Cha, Wis
            {
              r.addAll([
                'Ranger (Fey Wanderer)',
                'Storm Sorcerer (Dwarf, with 2 Tempest Cleric levels)',
              ]);
              break;
            }
        }
        break;
      }
  }
  return r;
}
