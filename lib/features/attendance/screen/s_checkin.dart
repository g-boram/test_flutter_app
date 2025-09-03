import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:test_app/shared/layout/l_feature_layout.dart';


class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeatureLayout(
      titleKey: 'check_in.title',
      // bottomDescKey: 'check_in.bottom_text',
      bottom: TabBar(
        controller: _tab,
        tabs: [
          Tab(text: 'checkin.qrTab'.tr()),
          Tab(text: 'checkin.manualTab'.tr()),
        ],
      ),
      child: TabBarView(
        controller: _tab,
        children: [
          _QrTab(onResult: (code) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan: $code')));
            // TODO: 서버 전송 / 오프라인 큐 저장
          }),
          const _ManualTab(),
        ],
      ),
    );
  }
}

class _QrTab extends StatelessWidget {
  final void Function(String code) onResult;
  const _QrTab({required this.onResult});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          fit: BoxFit.cover,
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            final raw = barcode?.rawValue;
            if (raw != null) onResult(raw);
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text('checkin.qrGuide'.tr(), style: Theme.of(context).textTheme.headlineMedium),
          ),
        ),
      ],
    );
  }
}

class _ManualTab extends StatefulWidget {
  const _ManualTab();

  @override
  State<_ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<_ManualTab> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('checkin.manual.guide'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'checkin.manual.placeholder'.tr(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final id = _controller.text.trim();
                if (id.isEmpty) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('입력: $id')));
                // TODO: 서버 전송 / 오프라인 큐 저장
              },
              child: Text('checkin.manual.submit'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
