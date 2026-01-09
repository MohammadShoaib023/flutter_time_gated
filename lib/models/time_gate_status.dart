class TimeGateStatus {
  final bool isStageOneComplete;
  final bool canEnterStageTwo;
  final Duration remaining;
  final bool isTamperingDetected;
  final String? warning;

  const TimeGateStatus({
    required this.isStageOneComplete,
    required this.canEnterStageTwo,
    required this.remaining,
    required this.isTamperingDetected,
    this.warning,
  });
}
