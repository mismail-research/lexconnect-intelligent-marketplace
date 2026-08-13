import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexbid/core/constants/app_color.dart';

/// Bell icon whose badge reflects the number of *highlighted* (unseen)
/// appointment cards for this user, queried live from the
/// `appointments` collection — never a separately maintained counter.
class NotificationBellIcon extends StatelessWidget {
  final String collection; // 'lawyers' or 'clients'
  final String uid;
  final VoidCallback onTap;

  const NotificationBellIcon({
    super.key,
    required this.collection,
    required this.uid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLawyer = collection == 'lawyers';

    final query = FirebaseFirestore.instance
        .collection('appointments')
        .where(isLawyer ? 'lawyerUid' : 'clientUid', isEqualTo: uid)
        .where(isLawyer ? 'isSeenByLawyer' : 'isSeenByClient',
        isEqualTo: false);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final unread = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                size: 30,
                color: AppColors.darkContrast,
              ),
              onPressed: onTap,
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.redColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.backgroundColor,
                        width: 1.5,
                      ),
                    ),
                    constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}