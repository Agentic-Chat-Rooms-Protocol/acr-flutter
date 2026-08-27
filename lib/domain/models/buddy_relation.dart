enum BuddyStatus {
  pending,
  accepted,
  blocked;

  static BuddyStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'accepted':
        return BuddyStatus.accepted;
      case 'blocked':
        return BuddyStatus.blocked;
      case 'pending':
      default:
        return BuddyStatus.pending;
    }
  }

  String toSerializedString() {
    switch (this) {
      case BuddyStatus.accepted:
        return 'accepted';
      case BuddyStatus.blocked:
        return 'blocked';
      case BuddyStatus.pending:
        return 'pending';
    }
  }
}

class BuddyRelation {
  const BuddyRelation({
    required this.fromDid,
    required this.toDid,
    required this.status,
    required this.createdAt,
  });

  factory BuddyRelation.fromJson(Map<String, dynamic> json) {
    return BuddyRelation(
      fromDid: json['from_did'] as String? ?? '',
      toDid: json['to_did'] as String? ?? '',
      status: BuddyStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  final String fromDid;
  final String toDid;
  final BuddyStatus status;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'from_did': fromDid,
        'to_did': toDid,
        'status': status.toSerializedString(),
        'created_at': createdAt,
      };
}
