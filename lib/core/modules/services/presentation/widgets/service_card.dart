import 'package:bedaya2/core/modules/services/models/hospital_service_model.dart';
import 'package:bedaya2/core/theme/styles.dart';
import 'package:bedaya2/core/modules/services/presentation/pages/service_details_page.dart';
import 'package:flutter/material.dart';
import 'package:html2md/html2md.dart' as html2md;

class ServiceCard extends StatelessWidget {
  final String label;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final HospitalServiceApiModel service;

  const ServiceCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.title,
    required this.description,
    required this.icon,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsPage(service: service),
          ),
        );
      },
      child: Container(
        width: 330,
        padding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2, color: const Color(0xFFB9C8D3)),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Icon(icon, color: Colors.blueGrey),
                      ),
                      Text(
                        label,
                        style: AppStyles.bodyMedium.copyWith(
                          color: Colors.teal,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    width: 36,
                    height: 36,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Icon(
                      Icons.check_circle_outline_outlined,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  SizedBox(
                    width: 246,
                    child: Text(
                      service.titleLocalized(context),
                      style: AppStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 282,
                    child: Text(
                      html2md.convert(
                        service.shortDescription(context, maxLength: 100),
                      ), // Limit to 100 characters
                      style: AppStyles.bodyMedium.copyWith(
                        color: Colors.blueGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
