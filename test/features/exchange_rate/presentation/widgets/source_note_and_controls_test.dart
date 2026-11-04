import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/currency_pair.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/widgets/currency_selector_card.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/widgets/period_segmented_control.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/widgets/source_note_widget.dart';

void main() {
  group('Source Note & Control Widgets (TC-Widget-1, 2, 7)', () {
    testWidgets(
      'TC-Widget-5.1: CurrencySelectorCard renders currency pair and triggers onTap callback',
      (tester) async {
        bool tapped = false;

        // Given: การ์ดคู่สกุลเงิน USD -> THB
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: CurrencySelectorCard(
                  pair: const CurrencyPair(base: 'USD', quote: 'THB'),
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        );

        // Assert: แสดงผล 'USD → THB' และไอคอน chevron_right
        expect(find.text('USD → THB'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);

        // When: แตะที่การ์ด
        await tester.tap(find.byType(CurrencySelectorCard));
        await tester.pump();

        // Assert: Callback onTap ถูกทริกเกอร์
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'TC-Widget-5.2: PeriodSegmentedControl renders 3 period tabs and handles selection and loading lock',
      (tester) async {
        int? selectedDays;

        // 1. เคสปกติ: ไม่ได้โหลดอยู่ (isLoading = false)
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    return PeriodSegmentedControl(
                      selectedDays: selectedDays ?? 30,
                      isLoading: false,
                      onPeriodSelected: (days) {
                        setState(() {
                          selectedDays = days;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Assert: มีแท็บ 7 วัน, 30 วัน, 90 วัน ครบทั้งสาม
        expect(find.text('7 วัน'), findsOneWidget);
        expect(find.text('30 วัน'), findsOneWidget);
        expect(find.text('90 วัน'), findsOneWidget);

        // When: แตะแท็บ '7 วัน'
        await tester.tap(find.text('7 วัน'));
        await tester.pump();
        expect(selectedDays, 7);

        // 2. เคสล็อกปุ่ม: ขณะโหลดข้อมูล (isLoading = true) ตาม FR-3 / BR-2
        int? lockedSelection;
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PeriodSegmentedControl(
                  selectedDays: 30,
                  isLoading: true,
                  onPeriodSelected: (days) => lockedSelection = days,
                ),
              ),
            ),
          ),
        );

        // When: แตะ '90 วัน' ขณะโหลด
        await tester.tap(find.text('90 วัน'));
        await tester.pump();

        // Assert: Callback ต้องไม่ถูกเรียก
        expect(lockedSelection, isNull);
      },
    );

    testWidgets(
      'TC-Widget-5.3: SourceNoteWidget renders Frankfurter attribution and external link icon wrapped in InkWell',
      (tester) async {
        // Given: วิดเจ็ต SourceNoteWidget
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: Scaffold(body: SourceNoteWidget())),
          ),
        );

        // Assert: ตรวจพบข้อความและไอคอนตาม Figma EL-fb0e5f3d
        expect(
          find.text('อัตราแลกเปลี่ยนจาก Frankfurter (frankfurter.dev)'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
        expect(find.byIcon(Icons.open_in_new), findsOneWidget);
        expect(find.byType(InkWell), findsOneWidget);
      },
    );
  });
}
