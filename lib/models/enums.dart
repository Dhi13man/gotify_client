enum PriorityType {
  min,
  low,
  medium,
  high,
  max;

  static const int minValue = 0;
  static const int lowValue = 2;
  static const int mediumValue = 5;
  static const int highValue = 7;
  static const int maxValue = 10;

  const PriorityType();

  factory PriorityType.fromNumeric(int priority) {
    if (priority >= minValue && priority <= maxValue) {
      return PriorityType.values.firstWhere((p) => p.numericValue >= priority);
    } else {
      throw ArgumentError('Invalid priority number');
    }
  }

  int get numericValue {
    switch (this) {
      case PriorityType.min:
        return minValue;
      case PriorityType.low:
        return lowValue;
      case PriorityType.medium:
        return mediumValue;
      case PriorityType.high:
        return highValue;
      case PriorityType.max:
        return maxValue;
    }
  }

  @override
  String toString() {
    switch (this) {
      case PriorityType.min:
        return 'Min Priority';
      case PriorityType.low:
        return 'Low Priority';
      case PriorityType.medium:
        return 'Medium Priority';
      case PriorityType.high:
        return 'High Priority';
      case PriorityType.max:
        return 'Max Priority';
    }
  }
}
