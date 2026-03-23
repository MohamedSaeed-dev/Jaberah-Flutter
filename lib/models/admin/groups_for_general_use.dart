class GroupsForGeneralUse {
  int? id;
  String groupName;

  GroupsForGeneralUse({required this.id, required this.groupName});

  factory GroupsForGeneralUse.fromJson(Map<String, dynamic> json) {
    return GroupsForGeneralUse(
        id: json["id"] as int, groupName: json["groupName"] as String);
  }
}
