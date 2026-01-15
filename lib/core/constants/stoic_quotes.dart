/// Recovery phase for quote targeting.
///
/// Each phase corresponds to a stage in the recovery journey:
/// - [early]: Days 1-14 - Focus on perseverance and immediate strength
/// - [growing]: Days 15-60 - Focus on discipline and habit formation
/// - [strong]: Days 60+ - Focus on wisdom and long-term perspective
enum QuotePhase {
  /// Days 1-14: Encouraging quotes about strength through struggle
  early,

  /// Days 15-60: Quotes about growth, discipline, and habit formation
  growing,

  /// Days 60+: Quotes about wisdom, virtue, and perspective
  strong,
}

/// A Stoic quote with author attribution and phase targeting.
class StoicQuote {
  /// The quote text.
  final String text;

  /// The author of the quote.
  final String author;

  /// The recovery phase this quote is most appropriate for.
  final QuotePhase phase;

  const StoicQuote({
    required this.text,
    required this.author,
    required this.phase,
  });
}

/// Stoic quotes database with phase-aware selection.
///
/// Provides daily quotes from Marcus Aurelius, Seneca, and Epictetus,
/// tailored to the user's current recovery phase.
class StoicQuotes {
  // ============================================================
  // EARLY PHASE QUOTES (Days 1-14)
  // Theme: Perseverance, strength through struggle, getting started
  // ============================================================
  static const List<StoicQuote> _earlyQuotes = [
    // Marcus Aurelius
    StoicQuote(
      text:
          'The impediment to action advances action. What stands in the way becomes the way.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'You have power over your mind - not outside events. Realize this, and you will find strength.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Never let the future disturb you. You will meet it, if you have to, with the same weapons of reason which today arm you against the present.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Begin - to begin is half the work, let half still remain; again begin this, and thou wilt have finished.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'When you arise in the morning, think of what a precious privilege it is to be alive - to breathe, to think, to enjoy, to love.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'It is not death that a man should fear, but he should fear never beginning to live.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Accept the things to which fate binds you, and love the people with whom fate brings you together.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'The soul becomes dyed with the color of its thoughts.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Very little is needed to make a happy life; it is all within yourself, in your way of thinking.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'Confine yourself to the present.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Be like the cliff against which the waves continually break; but it stands firm and tames the fury of the water around it.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'The best revenge is not to be like your enemy.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.early,
    ),

    // Seneca
    StoicQuote(
      text:
          'It is not that we have a short time to live, but that we waste a lot of it.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'We suffer more often in imagination than in reality.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'Difficulties strengthen the mind, as labor does the body.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Begin at once to live, and count each separate day as a separate life.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'It is not the man who has too little, but the man who craves more, that is poor.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'Sometimes even to live is an act of courage.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'The greatest obstacle to living is expectancy, which hangs upon tomorrow and loses today.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'He who is brave is free.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'There is no easy way from the earth to the stars.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'A gem cannot be polished without friction, nor a man perfected without trials.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'While we wait for life, life passes.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'Every new beginning comes from some other beginning\'s end.',
      author: 'Seneca',
      phase: QuotePhase.early,
    ),

    // Epictetus
    StoicQuote(
      text:
          'It\'s not what happens to you, but how you react to it that matters.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Make the best use of what is in your power, and take the rest as it happens.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'First say to yourself what you would be; and then do what you have to do.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'No man is free who is not master of himself.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'He is a wise man who does not grieve for the things which he has not, but rejoices for those which he has.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'Caretake this moment. Immerse yourself in its particulars.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Man is not worried by real problems so much as by his imagined anxieties about real problems.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Circumstances don\'t make the man, they only reveal him to himself.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text: 'Any person capable of angering you becomes your master.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'Wealth consists not in having great possessions, but in having few wants.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'If you want to improve, be content to be thought foolish and stupid.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
    StoicQuote(
      text:
          'The key is to keep company only with people who uplift you, whose presence calls forth your best.',
      author: 'Epictetus',
      phase: QuotePhase.early,
    ),
  ];

  // ============================================================
  // GROWING PHASE QUOTES (Days 15-60)
  // Theme: Discipline, habit formation, becoming better
  // ============================================================
  static const List<StoicQuote> _growingQuotes = [
    // Marcus Aurelius
    StoicQuote(
      text:
          'Waste no more time arguing about what a good man should be. Be one.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'The object of life is not to be on the side of the majority, but to escape finding oneself in the ranks of the insane.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'If it is not right do not do it; if it is not true do not say it.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'The happiness of your life depends upon the quality of your thoughts.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'How much more grievous are the consequences of anger than the causes of it.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'Look well into thyself; there is a source of strength which will always spring up if thou wilt always look.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'Everything we hear is an opinion, not a fact. Everything we see is a perspective, not the truth.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'Receive without conceit, release without struggle.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'The only wealth which you will keep forever is the wealth you have given away.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'Do every act of your life as though it were the very last act of your life.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'Adapt yourself to the things among which your lot has been cast and love sincerely the fellow creatures with whom destiny has ordained that you shall live.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'He who lives in harmony with himself lives in harmony with the universe.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.growing,
    ),

    // Seneca
    StoicQuote(
      text: 'Luck is what happens when preparation meets opportunity.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'As is a tale, so is life: not how long it is, but how good it is, is what matters.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'True happiness is to enjoy the present, without anxious dependence upon the future.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'No man was ever wise by chance.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'We are more often frightened than hurt; and we suffer more from imagination than from reality.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'Associate with people who are likely to improve you.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'If a man knows not to which port he sails, no wind is favorable.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'It is quality rather than quantity that matters.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'Life is long if you know how to use it.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'Most powerful is he who has himself in his own power.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'We learn not in the school, but in life.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'You act like mortals in all that you fear, and like immortals in all that you desire.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'He who fears death will never do anything worthy of a man who is alive.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'The mind that is anxious about future events is miserable.',
      author: 'Seneca',
      phase: QuotePhase.growing,
    ),

    // Epictetus
    StoicQuote(
      text: 'Don\'t explain your philosophy. Embody it.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'If you wish to be a writer, write.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'Only the educated are free.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'We have two ears and one mouth so that we can listen twice as much as we speak.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'To accuse others for one\'s own misfortunes is a sign of want of education.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'It is impossible for a man to learn what he thinks he already knows.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'Practice yourself, for heaven\'s sake, in little things; and thence proceed to greater.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'The greater the difficulty, the more glory in surmounting it.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'Progress is not achieved by luck or accident, but by working on yourself daily.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'Neither should a ship rely on one small anchor, nor should life rest on a single hope.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text: 'Know, first, who you are, and then adorn yourself accordingly.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
    StoicQuote(
      text:
          'Freedom is the only worthy goal in life. It is won by disregarding things that lie beyond our control.',
      author: 'Epictetus',
      phase: QuotePhase.growing,
    ),
  ];

  // ============================================================
  // STRONG PHASE QUOTES (Days 60+)
  // Theme: Wisdom, virtue, long-term perspective, gratitude
  // ============================================================
  static const List<StoicQuote> _strongQuotes = [
    // Marcus Aurelius
    StoicQuote(
      text:
          'Dwell on the beauty of life. Watch the stars, and see yourself running with them.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'What we do now echoes in eternity.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'The art of living is more like wrestling than dancing.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'Loss is nothing else but change, and change is Nature\'s delight.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'A man\'s worth is no greater than his ambitions.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'How much trouble he avoids who does not look to see what his neighbor says or does or thinks.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Nothing happens to anybody which he is not fitted by nature to bear.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Time is a sort of river of passing events, and strong is its current.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Natural ability without education has more often raised a man to glory and virtue than education without natural ability.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'Death smiles at us all, but all a man can do is smile back.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'The universe is change; our life is what our thoughts make it.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'Execute every act of thy life as though it were thy last.',
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          "Here is a rule to remember in future, when anything tempts you to feel bitter: not 'This is misfortune,' but 'To bear this worthily is good fortune.'",
      author: 'Marcus Aurelius',
      phase: QuotePhase.strong,
    ),

    // Seneca
    StoicQuote(
      text:
          'Enjoy present pleasures in such a way as not to injure future ones.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'While we are postponing, life speeds by.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Religion is regarded by the common people as true, by the wise as false, and by rulers as useful.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'The whole future lies in uncertainty: live immediately.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'All cruelty springs from weakness.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Hang on to your youthful enthusiasms - you\'ll be able to use them better when you\'re older.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'That which Fortune has not given, she cannot take away.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'We become wiser by adversity; prosperity destroys our appreciation of the right.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'What need is there to weep over parts of life? The whole of it calls for tears.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Wherever there is a human being, there is an opportunity for a kindness.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'Nothing is more honorable than a grateful heart.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'It is not the man who has too little that is poor, but the one who hankers after more.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'Fire tests gold, suffering tests brave men.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'He suffers more than necessary, who suffers before it is necessary.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'A sword never kills anybody; it is a tool in the killer\'s hand.',
      author: 'Seneca',
      phase: QuotePhase.strong,
    ),

    // Epictetus
    StoicQuote(
      text:
          'There is only one way to happiness and that is to cease worrying about things which are beyond the power of our will.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Other people\'s views and troubles can be contagious. Don\'t sabotage yourself by unwittingly adopting negative, unproductive attitudes.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'If you want to be a good reader, read; if you want to be a good writer, write.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'The essence of philosophy is that a man should so live that his happiness shall depend as little as possible on external things.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Seeking the very best in ourselves means actively caring for the welfare of other human beings.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Be careful to leave your sons well instructed rather than rich, for the hopes of the instructed are better than the wealth of the ignorant.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'You are a little soul carrying around a corpse.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'Control thy passions lest they take vengeance on thee.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'Whoever does not regard what he has as most ample wealth, is unhappy, though he be master of the world.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text: 'God has entrusted me with myself.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'People are not disturbed by things, but by the views they take of them.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
    StoicQuote(
      text:
          'We are not privy to the stories behind people\'s actions, so we should be patient with others and suspend judgement of them.',
      author: 'Epictetus',
      phase: QuotePhase.strong,
    ),
  ];

  /// All quotes combined for convenience.
  static const List<StoicQuote> allQuotes = [
    ..._earlyQuotes,
    ..._growingQuotes,
    ..._strongQuotes,
  ];

  /// Determines the recovery phase based on sober days.
  ///
  /// - Days 1-14: [QuotePhase.early]
  /// - Days 15-60: [QuotePhase.growing]
  /// - Days 60+: [QuotePhase.strong]
  static QuotePhase getPhaseForDays(int soberDays) {
    if (soberDays <= 14) {
      return QuotePhase.early;
    } else if (soberDays <= 60) {
      return QuotePhase.growing;
    } else {
      return QuotePhase.strong;
    }
  }

  /// Gets quotes filtered by a specific phase.
  static List<StoicQuote> getQuotesForPhase(QuotePhase phase) {
    switch (phase) {
      case QuotePhase.early:
        return _earlyQuotes;
      case QuotePhase.growing:
        return _growingQuotes;
      case QuotePhase.strong:
        return _strongQuotes;
    }
  }

  /// Returns a quote appropriate for the user's recovery phase.
  ///
  /// Uses [dayOfYear] (1-365) to deterministically select a quote from
  /// the appropriate phase based on [soberDays]. This ensures the same
  /// quote is shown throughout a given day.
  ///
  /// Example:
  /// ```dart
  /// final quote = StoicQuotes.getQuoteForDay(dayOfYear: 42, soberDays: 7);
  /// print('${quote.text} - ${quote.author}');
  /// ```
  static StoicQuote getQuoteForDay({
    required int dayOfYear,
    required int soberDays,
  }) {
    final phase = getPhaseForDays(soberDays);
    final phaseQuotes = getQuotesForPhase(phase);

    // Use dayOfYear to cycle through quotes within the phase
    final index = dayOfYear % phaseQuotes.length;
    return phaseQuotes[index];
  }

  /// Convenience method that extracts dayOfYear from a [DateTime].
  ///
  /// Returns a quote appropriate for the given date and recovery phase.
  ///
  /// Example:
  /// ```dart
  /// final quote = StoicQuotes.getDailyQuote(
  ///   date: DateTime.now(),
  ///   soberDays: 30,
  /// );
  /// ```
  static StoicQuote getDailyQuote({
    required DateTime date,
    required int soberDays,
  }) {
    final dayOfYear = _getDayOfYear(date);
    return getQuoteForDay(dayOfYear: dayOfYear, soberDays: soberDays);
  }

  /// Returns a random quote from the specified phase.
  ///
  /// Useful for testing or when you want variety beyond the daily quote.
  static StoicQuote getRandomQuote(QuotePhase phase) {
    final phaseQuotes = getQuotesForPhase(phase);
    final index = DateTime.now().microsecond % phaseQuotes.length;
    return phaseQuotes[index];
  }

  /// Calculates the day of year (1-366) for a given date.
  static int _getDayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final difference = date.difference(startOfYear);
    return difference.inDays + 1;
  }

  /// Returns the total number of quotes in the database.
  static int get totalQuoteCount => allQuotes.length;

  /// Returns the count of quotes for each phase.
  static Map<QuotePhase, int> get quoteCountByPhase => {
    QuotePhase.early: _earlyQuotes.length,
    QuotePhase.growing: _growingQuotes.length,
    QuotePhase.strong: _strongQuotes.length,
  };
}
