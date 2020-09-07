class ServerInfo {
  static final String serverUrl = '121.196.127.61';
  static final int serverPort = 8080;
}

class Pinyin {
  static final initials = [
    'b',
    'p',
    'm',
    'f',
    'd',
    't',
    'n',
    'l',
    'g',
    'k',
    'h',
    'j',
    'q',
    'x',
    'zh',
    'ch',
    'sh',
    'r',
    'z',
    'c',
    's',
    'y',
    'w'
  ];

  static final consonant2Tone = {
    "a": 0,
    "ā": 1,
    "á": 2,
    "ǎ": 3,
    "à": 4,
    "ai": 0,
    "āi": 1,
    "ái": 2,
    "ǎi": 3,
    "ài": 4,
    "an": 0,
    "ān": 1,
    "án": 2,
    "ǎn": 3,
    "àn": 4,
    "ang": 0,
    "āng": 1,
    "áng": 2,
    "ǎng": 3,
    "àng": 4,
    "ao": 0,
    "āo": 1,
    "áo": 2,
    "ǎo": 3,
    "ào": 4,
    "e": 0,
    "ē": 1,
    "é": 2,
    "ě": 3,
    "è": 4,
    "ei": 0,
    "ēi": 1,
    "éi": 2,
    "ěi": 3,
    "èi": 4,
    "en": 0,
    "ēn": 1,
    "én": 2,
    "ěn": 3,
    "èn": 4,
    "eng": 0,
    "ēng": 1,
    "éng": 2,
    "ěng": 3,
    "èng": 4,
    "er": 0,
    "ēr": 1,
    "ér": 2,
    "ěr": 3,
    "èr": 4,
    "i": 0,
    "ī": 1,
    "í": 2,
    "ǐ": 3,
    "ì": 4,
    "ia": 0,
    "iā": 1,
    "iá": 2,
    "iǎ": 3,
    "ià": 4,
    "ian": 0,
    "iān": 1,
    "ián": 2,
    "iǎn": 3,
    "iàn": 4,
    "iang": 0,
    "iāng": 1,
    "iáng": 2,
    "iǎng": 3,
    "iàng": 4,
    "iao": 0,
    "iāo": 1,
    "iáo": 2,
    "iǎo": 3,
    "iào": 4,
    "ie": 0,
    "iē": 1,
    "ié": 2,
    "iě": 3,
    "iè": 4,
    "in": 0,
    "īn": 1,
    "ín": 2,
    "ǐn": 3,
    "ìn": 4,
    "ing": 0,
    "īng": 1,
    "íng": 2,
    "ǐng": 3,
    "ìng": 4,
    "iong": 0,
    "iōng": 1,
    "ióng": 2,
    "iǒng": 3,
    "iòng": 4,
    "iu": 0,
    "iū": 1,
    "iú": 2,
    "iǔ": 3,
    "iù": 4,
    "o": 0,
    "ō": 1,
    "ó": 2,
    "ǒ": 3,
    "ò": 4,
    "ong": 0,
    "ōng": 1,
    "óng": 2,
    "ǒng": 3,
    "òng": 4,
    "ou": 0,
    "ōu": 1,
    "óu": 2,
    "ǒu": 3,
    "òu": 4,
    "u": 0,
    "ū": 1,
    "ú": 2,
    "ǔ": 3,
    "ù": 4,
    "ua": 0,
    "uā": 1,
    "uá": 2,
    "uǎ": 3,
    "uà": 4,
    "uai": 0,
    "uāi": 1,
    "uái": 2,
    "uǎi": 3,
    "uài": 4,
    "uan": 0,
    "uān": 1,
    "uán": 2,
    "uǎn": 3,
    "uàn": 4,
    "uang": 0,
    "uāng": 1,
    "uáng": 2,
    "uǎng": 3,
    "uàng": 4,
    "ui": 0,
    "uī": 1,
    "uí": 2,
    "uǐ": 3,
    "uì": 4,
    "un": 0,
    "ūn": 1,
    "ún": 2,
    "ǔn": 3,
    "ùn": 4,
    "uo": 0,
    "uō": 1,
    "uó": 2,
    "uǒ": 3,
    "uò": 4,
    "ü": 0,
    "ǖ": 1,
    "ǘ": 2,
    "ǚ": 3,
    "ǜ": 4,
    "üan": 0,
    "ǖan": 1,
    "ǘan": 2,
    "ǚan": 3,
    "ǜan": 4,
    "ue": 0,
    "uē": 1,
    "ué": 2,
    "uě": 3,
    "uè": 4,
    "ün": 0,
    "ǖn": 1,
    "ǘn": 2,
    "ǚn": 3,
    "ǜn": 4,
    "üe": 0,
    "üē": 1,
    "üé": 2,
    "üě": 3,
    "üè": 4,
  };

  static final consonant2Base = {
    "a": "a",
    "ā": "a",
    "á": "a",
    "ǎ": "a",
    "à": "a",
    "ai": "ai",
    "āi": "ai",
    "ái": "ai",
    "ǎi": "ai",
    "ài": "ai",
    "an": "an",
    "ān": "an",
    "án": "an",
    "ǎn": "an",
    "àn": "an",
    "ang": "ang",
    "āng": "ang",
    "áng": "ang",
    "ǎng": "ang",
    "àng": "ang",
    "ao": "ao",
    "āo": "ao",
    "áo": "ao",
    "ǎo": "ao",
    "ào": "ao",
    "e": "e",
    "ē": "e",
    "é": "e",
    "ě": "e",
    "è": "e",
    "ei": "ei",
    "ēi": "ei",
    "éi": "ei",
    "ěi": "ei",
    "èi": "ei",
    "en": "en",
    "ēn": "en",
    "én": "en",
    "ěn": "en",
    "èn": "en",
    "eng": "eng",
    "ēng": "eng",
    "éng": "eng",
    "ěng": "eng",
    "èng": "eng",
    "er": "er",
    "ēr": "er",
    "ér": "er",
    "ěr": "er",
    "èr": "er",
    "i": "i",
    "ī": "ı",
    "í": "ı",
    "ǐ": "ı",
    "ì": "ı",
    "ia": "ia",
    "iā": "ia",
    "iá": "ia",
    "iǎ": "ia",
    "ià": "ia",
    "ian": "ian",
    "iān": "ian",
    "ián": "ian",
    "iǎn": "ian",
    "iàn": "ian",
    "iang": "iang",
    "iāng": "iang",
    "iáng": "iang",
    "iǎng": "iang",
    "iàng": "iang",
    "iao": "iao",
    "iāo": "iao",
    "iáo": "iao",
    "iǎo": "iao",
    "iào": "iao",
    "ie": "ie",
    "iē": "ie",
    "ié": "ie",
    "iě": "ie",
    "iè": "ie",
    "in": "in",
    "īn": "ın",
    "ín": "ın",
    "ǐn": "ın",
    "ìn": "ın",
    "ing": "ing",
    "īng": "ıng",
    "íng": "ıng",
    "ǐng": "ıng",
    "ìng": "ıng",
    "iong": "iong",
    "iōng": "iong",
    "ióng": "iong",
    "iǒng": "iong",
    "iòng": "iong",
    "iu": "iu",
    "iū": "iu",
    "iú": "iu",
    "iǔ": "iu",
    "iù": "iu",
    "o": "o",
    "ō": "o",
    "ó": "o",
    "ǒ": "o",
    "ò": "o",
    "ong": "ong",
    "ōng": "ong",
    "óng": "ong",
    "ǒng": "ong",
    "òng": "ong",
    "ou": "ou",
    "ōu": "ou",
    "óu": "ou",
    "ǒu": "ou",
    "òu": "ou",
    "u": "u",
    "ū": "u",
    "ú": "u",
    "ǔ": "u",
    "ù": "u",
    "ua": "ua",
    "uā": "ua",
    "uá": "ua",
    "uǎ": "ua",
    "uà": "ua",
    "uai": "uai",
    "uāi": "uai",
    "uái": "uai",
    "uǎi": "uai",
    "uài": "uai",
    "uan": "uan",
    "uān": "uan",
    "uán": "uan",
    "uǎn": "uan",
    "uàn": "uan",
    "uang": "uang",
    "uāng": "uang",
    "uáng": "uang",
    "uǎng": "uang",
    "uàng": "uang",
    "ui": "ui",
    "uī": "uı",
    "uí": "uı",
    "uǐ": "uı",
    "uì": "uı",
    "un": "un",
    "ūn": "un",
    "ún": "un",
    "ǔn": "un",
    "ùn": "un",
    "uo": "uo",
    "uō": "uo",
    "uó": "uo",
    "uǒ": "uo",
    "uò": "uo",
    "ü": "ü",
    "ǖ": "ü",
    "ǘ": "ü",
    "ǚ": "ü",
    "ǜ": "ü",
    "üan": "üan",
    "ǖan": "üan",
    "ǘan": "üan",
    "ǚan": "üan",
    "ǜan": "üan",
    "ue": "ue",
    "uē": "ue",
    "ué": "ue",
    "uě": "ue",
    "uè": "ue",
    "ün": "ün",
    "ǖn": "ün",
    "ǘn": "ün",
    "ǚn": "ün",
    "ǜn": "ün",
    "üe": "üe",
    "üē": "üe",
    "üé": "üe",
    "üě": "üe",
    "üè": "üe",
  };

/*
  static final consonant2TonePos = {
    "a": 0,
    "ā": 0,
    "á": 0,
    "ǎ": 0,
    "à": 0,
    "ai": 0,
    "āi": 0,
    "ái": 0,
    "ǎi": 0,
    "ài": 0,
    "an": 0,
    "ān": 0,
    "án": 0,
    "ǎn": 0,
    "àn": 0,
    "ang": 0,
    "āng": 0,
    "áng": 0,
    "ǎng": 0,
    "àng": 0,
    "ao": 0,
    "āo": 0,
    "áo": 0,
    "ǎo": 0,
    "ào": 0,
    "e": 0,
    "ē": 0,
    "é": 0,
    "ě": 0,
    "è": 0,
    "ei": 0,
    "ēi": 0,
    "éi": 0,
    "ěi": 0,
    "èi": 0,
    "en": 0,
    "ēn": 0,
    "én": 0,
    "ěn": 0,
    "èn": 0,
    "eng": 0,
    "ēng": 0,
    "éng": 0,
    "ěng": 0,
    "èng": 0,
    "er": 0,
    "ēr": 0,
    "ér": 0,
    "ěr": 0,
    "èr": 0,
    "i": 0,
    "ī": 0,
    "í": 0,
    "ǐ": 0,
    "ì": 0,
    "ia": 1,
    "iā": 1,
    "iá": 1,
    "iǎ": 1,
    "ià": 1,
    "ian": 1,
    "iān": 1,
    "ián": 1,
    "iǎn": 1,
    "iàn": 1,
    "iang": 1,
    "iāng": 1,
    "iáng": 1,
    "iǎng": 1,
    "iàng": 1,
    "iao": 1,
    "iāo": 1,
    "iáo": 1,
    "iǎo": 1,
    "iào": 1,
    "ie": 1,
    "iē": 1,
    "ié": 1,
    "iě": 1,
    "iè": 1,
    "in": 0,
    "īn": 0,
    "ín": 0,
    "ǐn": 0,
    "ìn": 0,
    "ing": 0,
    "īng": 0,
    "íng": 0,
    "ǐng": 0,
    "ìng": 0,
    "iong": 1,
    "iōng": 1,
    "ióng": 1,
    "iǒng": 1,
    "iòng": 1,
    "iu": 1,
    "iū": 1,
    "iú": 1,
    "iǔ": 1,
    "iù": 1,
    "o": 0,
    "ō": 0,
    "ó": 0,
    "ǒ": 0,
    "ò": 0,
    "ong": 0,
    "ōng": 0,
    "óng": 0,
    "ǒng": 0,
    "òng": 0,
    "ou": 0,
    "ōu": 0,
    "óu": 0,
    "ǒu": 0,
    "òu": 0,
    "u": 0,
    "ū": 0,
    "ú": 0,
    "ǔ": 0,
    "ù": 0,
    "ua": 1,
    "uā": 1,
    "uá": 1,
    "uǎ": 1,
    "uà": 1,
    "uai": 1,
    "uāi": 1,
    "uái": 1,
    "uǎi": 1,
    "uài": 1,
    "uan": 1,
    "uān": 1,
    "uán": 1,
    "uǎn": 1,
    "uàn": 1,
    "uang": 1,
    "uāng": 1,
    "uáng": 1,
    "uǎng": 1,
    "uàng": 1,
    "ui": 1,
    "uī": 1,
    "uí": 1,
    "uǐ": 1,
    "uì": 1,
    "un": 0,
    "ūn": 0,
    "ún": 0,
    "ǔn": 0,
    "ùn": 0,
    "uo": 1,
    "uō": 1,
    "uó": 1,
    "uǒ": 1,
    "uò": 1,
    "ü": 0,
    "ǖ": 0,
    "ǘ": 0,
    "ǚ": 0,
    "ǜ": 0,
    "üan": 1,
    "ǖan": 1,
    "ǘan": 1,
    "ǚan": 1,
    "ǜan": 1,
    "ue": 1,
    "uē": 1,
    "ué": 1,
    "uě": 1,
    "uè": 1,
    "ün": 0,
    "ǖn": 0,
    "ǘn": 0,
    "ǚn": 0,
    "ǜn": 0,
    "üe": 1,
    "üē": 1,
    "üé": 1,
    "üě": 1,
    "üè": 1,
  };
   */
}
