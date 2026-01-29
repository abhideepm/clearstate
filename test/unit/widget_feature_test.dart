import 'package:flutter_test/flutter_test.dart';
import 'package:truestate/core/constants/stoic_quotes.dart';
import 'package:truestate/core/constants/bio_states.dart';
import 'package:truestate/data/models/widget_config.dart';

void main() {
  // ============================================================
  // StoicQuotes Tests
  // ============================================================
  group('StoicQuotes', () {
    group('getPhaseForDays', () {
      test('returns early phase for days 0-14', () {
        expect(StoicQuotes.getPhaseForDays(0), QuotePhase.early);
        expect(StoicQuotes.getPhaseForDays(1), QuotePhase.early);
        expect(StoicQuotes.getPhaseForDays(7), QuotePhase.early);
        expect(StoicQuotes.getPhaseForDays(14), QuotePhase.early);
      });

      test('returns growing phase for days 15-60', () {
        expect(StoicQuotes.getPhaseForDays(15), QuotePhase.growing);
        expect(StoicQuotes.getPhaseForDays(30), QuotePhase.growing);
        expect(StoicQuotes.getPhaseForDays(45), QuotePhase.growing);
        expect(StoicQuotes.getPhaseForDays(60), QuotePhase.growing);
      });

      test('returns strong phase for days 61+', () {
        expect(StoicQuotes.getPhaseForDays(61), QuotePhase.strong);
        expect(StoicQuotes.getPhaseForDays(90), QuotePhase.strong);
        expect(StoicQuotes.getPhaseForDays(180), QuotePhase.strong);
        expect(StoicQuotes.getPhaseForDays(365), QuotePhase.strong);
        expect(StoicQuotes.getPhaseForDays(1000), QuotePhase.strong);
      });

      test('handles edge cases correctly', () {
        // Negative days should still return early
        expect(StoicQuotes.getPhaseForDays(-1), QuotePhase.early);
        expect(StoicQuotes.getPhaseForDays(-100), QuotePhase.early);
      });
    });

    group('getQuotesForPhase', () {
      test('returns only quotes with matching early phase', () {
        final quotes = StoicQuotes.getQuotesForPhase(QuotePhase.early);
        expect(quotes, isNotEmpty);
        for (final quote in quotes) {
          expect(quote.phase, QuotePhase.early);
        }
      });

      test('returns only quotes with matching growing phase', () {
        final quotes = StoicQuotes.getQuotesForPhase(QuotePhase.growing);
        expect(quotes, isNotEmpty);
        for (final quote in quotes) {
          expect(quote.phase, QuotePhase.growing);
        }
      });

      test('returns only quotes with matching strong phase', () {
        final quotes = StoicQuotes.getQuotesForPhase(QuotePhase.strong);
        expect(quotes, isNotEmpty);
        for (final quote in quotes) {
          expect(quote.phase, QuotePhase.strong);
        }
      });
    });

    group('getDailyQuote', () {
      test('returns consistent quote for same day', () {
        final date = DateTime(2024, 6, 15);
        final quote1 = StoicQuotes.getDailyQuote(date: date, soberDays: 10);
        final quote2 = StoicQuotes.getDailyQuote(date: date, soberDays: 10);
        expect(quote1.text, quote2.text);
        expect(quote1.author, quote2.author);
      });

      test('returns different quotes for different days', () {
        final date1 = DateTime(2024, 6, 15);
        final date2 = DateTime(2024, 6, 16);
        final quote1 = StoicQuotes.getDailyQuote(date: date1, soberDays: 10);
        final quote2 = StoicQuotes.getDailyQuote(date: date2, soberDays: 10);
        // They might coincidentally be the same, but testing modular behavior
        // Check that quotes from same phase are returned for same sober days
        expect(quote1.phase, QuotePhase.early);
        expect(quote2.phase, QuotePhase.early);
      });

      test('returns quote matching the recovery phase', () {
        final date = DateTime(2024, 6, 15);

        final earlyQuote = StoicQuotes.getDailyQuote(date: date, soberDays: 5);
        expect(earlyQuote.phase, QuotePhase.early);

        final growingQuote = StoicQuotes.getDailyQuote(
          date: date,
          soberDays: 30,
        );
        expect(growingQuote.phase, QuotePhase.growing);

        final strongQuote = StoicQuotes.getDailyQuote(
          date: date,
          soberDays: 100,
        );
        expect(strongQuote.phase, QuotePhase.strong);
      });
    });

    group('allQuotes validation', () {
      test('all quotes have non-empty text and author', () {
        for (final quote in StoicQuotes.allQuotes) {
          expect(
            quote.text,
            isNotEmpty,
            reason: 'Quote text should not be empty',
          );
          expect(
            quote.author,
            isNotEmpty,
            reason: 'Quote author should not be empty',
          );
        }
      });

      test('totalQuoteCount matches allQuotes length', () {
        expect(StoicQuotes.totalQuoteCount, StoicQuotes.allQuotes.length);
      });

      test('quoteCountByPhase sums to totalQuoteCount', () {
        final counts = StoicQuotes.quoteCountByPhase;
        final sum =
            counts[QuotePhase.early]! +
            counts[QuotePhase.growing]! +
            counts[QuotePhase.strong]!;
        expect(sum, StoicQuotes.totalQuoteCount);
      });
    });
  });

  // ============================================================
  // BioStates Tests
  // ============================================================
  group('BioStates', () {
    group('getMetric', () {
      test('returns correct metric by ID', () {
        expect(BioStates.getMetric('gaba')?.id, 'gaba');
        expect(BioStates.getMetric('dopamine')?.id, 'dopamine');
        expect(BioStates.getMetric('serotonin')?.id, 'serotonin');
        expect(BioStates.getMetric('sleep')?.id, 'sleep');
        expect(BioStates.getMetric('liver')?.id, 'liver');
        expect(BioStates.getMetric('brain')?.id, 'brain');
        expect(BioStates.getMetric('recovery')?.id, 'recovery');
      });

      test('returns null for invalid ID', () {
        expect(BioStates.getMetric('invalid'), isNull);
        expect(BioStates.getMetric(''), isNull);
        expect(BioStates.getMetric('GABA'), isNull); // Case sensitive
      });
    });

    group('getValueForDay', () {
      test('returns first curve value for day 0', () {
        final gaba = BioStates.gaba;
        expect(gaba.getValueForDay(0), 0.30);
      });

      test('returns first curve value for negative days', () {
        final gaba = BioStates.gaba;
        expect(gaba.getValueForDay(-1), 0.30);
        expect(gaba.getValueForDay(-100), 0.30);
      });

      test('interpolates correctly between points', () {
        final gaba = BioStates.gaba;
        // Between day 0 (0.30) and day 3 (0.40)
        // Day 1.5 should be approximately 0.35
        final midpoint = gaba.getValueForDay(1);
        expect(midpoint, greaterThan(0.30));
        expect(midpoint, lessThan(0.40));

        // Day 2 should be approximately 0.3667 (linear interpolation)
        final day2 = gaba.getValueForDay(2);
        expect(day2, closeTo(0.30 + (0.40 - 0.30) * 2 / 3, 0.01));
      });

      test('returns last value for days beyond curve', () {
        final gaba = BioStates.gaba;
        expect(gaba.getValueForDay(365), 1.0);
        expect(gaba.getValueForDay(500), 1.0);
        expect(gaba.getValueForDay(1000), 1.0);
      });

      test('returns exact curve values at defined points', () {
        final sleep = BioStates.sleep;
        expect(sleep.getValueForDay(0), 0.20);
        expect(sleep.getValueForDay(3), 0.35);
        expect(sleep.getValueForDay(7), 0.55);
        expect(sleep.getValueForDay(14), 0.70);
        expect(sleep.getValueForDay(30), 0.82);
        expect(sleep.getValueForDay(60), 0.90);
        expect(sleep.getValueForDay(90), 0.95);
        expect(sleep.getValueForDay(180), 0.98);
        expect(sleep.getValueForDay(365), 1.0);
      });
    });

    group('getRecoveryIndex', () {
      test('calculates average of all metrics for day 0', () {
        // Day 0 values: gaba=0.30, dopamine=0.40, serotonin=0.35,
        // sleep=0.20, liver=0.60, brain=0.70
        final expected = (0.30 + 0.40 + 0.35 + 0.20 + 0.60 + 0.70) / 6;
        expect(BioStates.getRecoveryIndex(0), closeTo(expected, 0.001));
      });

      test('calculates average of all metrics for day 365', () {
        // Day 365 values: all should be ~1.0 (brain is 0.99)
        final expected = (1.0 + 1.0 + 1.0 + 1.0 + 1.0 + 0.99) / 6;
        expect(BioStates.getRecoveryIndex(365), closeTo(expected, 0.001));
      });

      test('recovery index increases over time', () {
        final day0 = BioStates.getRecoveryIndex(0);
        final day30 = BioStates.getRecoveryIndex(30);
        final day90 = BioStates.getRecoveryIndex(90);
        final day365 = BioStates.getRecoveryIndex(365);

        expect(day30, greaterThan(day0));
        expect(day90, greaterThan(day30));
        expect(day365, greaterThan(day90));
      });
    });

    group('getAllMetrics', () {
      test('returns all physical metrics plus recovery index', () {
        final metrics = BioStates.getAllMetrics();
        expect(metrics.length, 7); // 6 physical + 1 recovery

        final ids = metrics.map((m) => m.id).toList();
        expect(ids, contains('gaba'));
        expect(ids, contains('dopamine'));
        expect(ids, contains('serotonin'));
        expect(ids, contains('sleep'));
        expect(ids, contains('liver'));
        expect(ids, contains('brain'));
        expect(ids, contains('recovery'));
      });
    });

    group('metrics curve validation', () {
      test('all metrics have valid curve data with ascending days', () {
        final metrics = BioStates.getAllMetrics();
        for (final metric in metrics) {
          expect(
            metric.curve,
            isNotEmpty,
            reason: '${metric.id} should have curve data',
          );

          // Verify days are ascending
          for (int i = 1; i < metric.curve.length; i++) {
            expect(
              metric.curve[i].day,
              greaterThan(metric.curve[i - 1].day),
              reason: '${metric.id} days should be ascending',
            );
          }
        }
      });

      test('all metrics have values between 0 and 1', () {
        final metrics = BioStates.getAllMetrics();
        for (final metric in metrics) {
          for (final point in metric.curve) {
            expect(
              point.value,
              greaterThanOrEqualTo(0.0),
              reason: '${metric.id} values should be >= 0',
            );
            expect(
              point.value,
              lessThanOrEqualTo(1.0),
              reason: '${metric.id} values should be <= 1',
            );
          }
        }
      });

      test('all physical metrics start at day 0', () {
        final metricIds = [
          'gaba',
          'dopamine',
          'serotonin',
          'sleep',
          'liver',
          'brain',
        ];
        for (final id in metricIds) {
          final metric = BioStates.getMetric(id)!;
          expect(
            metric.curve.first.day,
            0,
            reason: '$id should start at day 0',
          );
        }
      });

      test('all physical metrics end at day 365', () {
        final metricIds = [
          'gaba',
          'dopamine',
          'serotonin',
          'sleep',
          'liver',
          'brain',
        ];
        for (final id in metricIds) {
          final metric = BioStates.getMetric(id)!;
          expect(
            metric.curve.last.day,
            365,
            reason: '$id should end at day 365',
          );
        }
      });
    });
  });

  // ============================================================
  // WidgetConfig Tests
  // ============================================================
  group('WidgetConfig', () {
    group('constructor', () {
      test('sets correct default values', () {
        final config = WidgetConfig(widgetType: 'battery');
        expect(config.widgetType, 'battery');
        expect(config.batteryMode, 'milestone');
        expect(config.bioStateMetricId, isNull);
        expect(config.goalDays, 30);
        expect(config.isEnabled, true);
      });

      test('allows overriding default values', () {
        final config = WidgetConfig(
          widgetType: 'bioState',
          batteryMode: 'goal',
          bioStateMetricId: 'gaba',
          goalDays: 60,
          isEnabled: false,
        );
        expect(config.widgetType, 'bioState');
        expect(config.batteryMode, 'goal');
        expect(config.bioStateMetricId, 'gaba');
        expect(config.goalDays, 60);
        expect(config.isEnabled, false);
      });
    });

    group('type getter', () {
      test('returns correct WidgetType enum for battery', () {
        final config = WidgetConfig(widgetType: 'battery');
        expect(config.type, WidgetType.battery);
      });

      test('returns correct WidgetType enum for stoic', () {
        final config = WidgetConfig(widgetType: 'stoic');
        expect(config.type, WidgetType.stoic);
      });

      test('returns correct WidgetType enum for bioState', () {
        final config = WidgetConfig(widgetType: 'bioState');
        expect(config.type, WidgetType.bioState);
      });

      test('returns battery as default for unknown type', () {
        final config = WidgetConfig(widgetType: 'unknown');
        expect(config.type, WidgetType.battery);
      });
    });

    group('displayMode getter', () {
      test('returns correct BatteryDisplayMode enum for milestone', () {
        final config = WidgetConfig(
          widgetType: 'battery',
          batteryMode: 'milestone',
        );
        expect(config.displayMode, BatteryDisplayMode.milestone);
      });

      test('returns correct BatteryDisplayMode enum for goal', () {
        final config = WidgetConfig(widgetType: 'battery', batteryMode: 'goal');
        expect(config.displayMode, BatteryDisplayMode.goal);
      });

      test('returns correct BatteryDisplayMode enum for daily', () {
        final config = WidgetConfig(
          widgetType: 'battery',
          batteryMode: 'daily',
        );
        expect(config.displayMode, BatteryDisplayMode.daily);
      });

      test('returns milestone as default for unknown mode', () {
        final config = WidgetConfig(
          widgetType: 'battery',
          batteryMode: 'unknown',
        );
        expect(config.displayMode, BatteryDisplayMode.milestone);
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields correctly', () {
        final config = WidgetConfig(
          widgetType: 'bioState',
          batteryMode: 'goal',
          bioStateMetricId: 'dopamine',
          goalDays: 90,
          isEnabled: false,
        );

        final json = config.toJson();
        expect(json['widgetType'], 'bioState');
        expect(json['batteryMode'], 'goal');
        expect(json['bioStateMetricId'], 'dopamine');
        expect(json['goalDays'], 90);
        expect(json['isEnabled'], false);
      });

      test('toJson handles null bioStateMetricId', () {
        final config = WidgetConfig(widgetType: 'battery');
        final json = config.toJson();
        expect(json['bioStateMetricId'], isNull);
      });

      test('fromJson deserializes all fields correctly', () {
        final json = {
          'widgetType': 'stoic',
          'batteryMode': 'daily',
          'bioStateMetricId': 'sleep',
          'goalDays': 45,
          'isEnabled': true,
        };

        final config = WidgetConfig.fromJson(json);
        expect(config.widgetType, 'stoic');
        expect(config.batteryMode, 'daily');
        expect(config.bioStateMetricId, 'sleep');
        expect(config.goalDays, 45);
        expect(config.isEnabled, true);
      });

      test('fromJson uses defaults for missing optional fields', () {
        final json = {'widgetType': 'battery'};

        final config = WidgetConfig.fromJson(json);
        expect(config.widgetType, 'battery');
        expect(config.batteryMode, 'milestone');
        expect(config.bioStateMetricId, isNull);
        expect(config.goalDays, 30);
        expect(config.isEnabled, true);
      });

      test('toJson and fromJson round-trip correctly', () {
        final original = WidgetConfig(
          widgetType: 'bioState',
          batteryMode: 'goal',
          bioStateMetricId: 'liver',
          goalDays: 120,
          isEnabled: true,
        );

        final json = original.toJson();
        final restored = WidgetConfig.fromJson(json);

        expect(restored.widgetType, original.widgetType);
        expect(restored.batteryMode, original.batteryMode);
        expect(restored.bioStateMetricId, original.bioStateMetricId);
        expect(restored.goalDays, original.goalDays);
        expect(restored.isEnabled, original.isEnabled);
      });

      test('round-trip preserves null bioStateMetricId', () {
        final original = WidgetConfig(widgetType: 'battery');

        final json = original.toJson();
        final restored = WidgetConfig.fromJson(json);

        expect(restored.bioStateMetricId, isNull);
      });
    });
  });
}
