import 'package:flutter/material.dart';

import '../controllers/time_gate_controller.dart';
import '../models/time_gate_status.dart';
import 'stage_two_view.dart';

class StageOneView extends StatefulWidget {
  const StageOneView({super.key});

  @override
  State<StageOneView> createState() => _StageOneViewState();
}

class _StageOneViewState extends State<StageOneView> {
  final List<String> stageOneSteps = const [
    'Step 1: Accept terms',
    'Step 2: Fill profile',
    'Step 3: Confirm details',
  ];

  late List<bool> checkedSteps;
  TimeGateStatus? gateStatus;

  @override
  void initState() {
    super.initState();
    checkedSteps = List<bool>.filled(stageOneSteps.length, false);
    _loadGateStatus();
  }

  Future<void> _loadGateStatus() async {
    final status = await TimeGateController.getGateStatus();
    if (!mounted) return;
    setState(() => gateStatus = status);
  }

  bool get allStepsComplete => checkedSteps.every((v) => v);

  Future<void> _completeStageOne() async {
    await TimeGateController.completeStageOne();
    await _loadGateStatus();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stage One completed. Wait 6 hours.')),
    );
  }

  Future<void> _openStageTwoIfAllowed() async {
    final status = await TimeGateController.getGateStatus();
    if (!mounted) return;

    if (status.isTamperingDetected) {
      final warning = status.warning ??
          'Time manipulation detected. Please reset your device clock to the correct time to continue.';
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Warning'),
          content: Text(warning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (!status.canEnterStageTwo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please wait: ${_formatDuration(status.remaining)}')),
      );
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const StageTwoView()));
  }

  Future<void> _resetProgress() async {
    await TimeGateController.resetProgress();
    setState(() {
      checkedSteps = List<bool>.filled(stageOneSteps.length, false);
      gateStatus = null;
    });
    await _loadGateStatus();
  }

  @override
  Widget build(BuildContext context) {
    final status = gateStatus;

    final isStageOneComplete = status?.isStageOneComplete ?? false;
    final canCompleteStageOne = allStepsComplete && !isStageOneComplete;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage One'),
        actions: [
          IconButton(
            onPressed: _resetProgress,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Complete steps. Then wait 6 real hours (uptime-based) before Stage Two.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...List.generate(stageOneSteps.length, (i) {
            return CheckboxListTile(
              title: Text(stageOneSteps[i]),
              value: checkedSteps[i],
              onChanged: isStageOneComplete
                  ? null
                  : (v) => setState(() => checkedSteps[i] = v ?? false),
            );
          }),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: canCompleteStageOne ? _completeStageOne : null,
            child: const Text('Finish Stage One'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          if (!isStageOneComplete)
            const Text('Stage One not completed yet.')
          else ...[
            Text(
              'Remaining: ${_formatDuration(status!.remaining)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _openStageTwoIfAllowed,
              child: const Text('Go to Stage Two'),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final hours = minutes ~/ 60;
  final leftoverMinutes = minutes % 60;
  return '${hours}h ${leftoverMinutes}m';
}
