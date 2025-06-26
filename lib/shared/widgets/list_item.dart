import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'container.dart';

class CustomListItem extends StatelessWidget {
  final String? title;
  final String? description;
  final List<String>? additionalTitles;
  final List<String>? additionalDescriptions;
  final EdgeInsetsGeometry padding;
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;
  final Widget? child;
  final bool isboxed;

  const CustomListItem({
    this.title,
    this.description,
    this.additionalTitles,
    this.additionalDescriptions,
    this.gradientColors = const [AppColors.lightSecondary, AppColors.primary],
    required this.begin,
    required this.end,
    this.trailingIcon,
    this.onPressed,
    this.child,
    Key? key,
    this.padding = const EdgeInsets.symmetric(horizontal: 32.0),
    this.isboxed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          CustomContainer(
            gradientColors: gradientColors,
            begin: end,
            end: begin,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            MediaQuery.of(context).size.width < 700 &&
                                    title!.length > 40
                                ? title!
                                        .split(' ')
                                        .take(title!.split(' ').length ~/ 2)
                                        .join(' ') +
                                    '\n' +
                                    title!
                                        .split(' ')
                                        .skip(title!.split(' ').length ~/ 2)
                                        .join(' ')
                                : title!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.darkPrimary,
                            ),
                          ),
                        if (description != null) ...[
                          Text(
                            MediaQuery.of(context).size.width < 700 &&
                                    description!.length > 40
                                ? description!
                                        .split(' ')
                                        .take(
                                            description!.split(' ').length ~/ 2)
                                        .join(' ') +
                                    '\n' +
                                    description!
                                        .split(' ')
                                        .skip(
                                            description!.split(' ').length ~/ 2)
                                        .join(' ')
                                : description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        if (additionalTitles != null &&
                            additionalDescriptions != null)
                          ...List.generate(additionalTitles!.length, (index) {
                            return Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${additionalTitles![index]}: ",
                                    style: TextStyle(
                                        color: AppColors.darkPrimary,
                                        fontSize: 15),
                                  ),
                                  TextSpan(
                                    text: additionalDescriptions![index].isEmpty
                                        ? "غير متوفر"
                                        : additionalDescriptions![index],
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                    if (trailingIcon != null && isboxed) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomContainer(
                          gradientColors: gradientColors,
                          begin: end,
                          end: begin,
                          padding: const EdgeInsets.all(2),
                          child: IconButton(
                            icon: trailingIcon!,
                            onPressed: onPressed,
                          ),
                        ),
                      ),
                    ],
                    if (trailingIcon != null && !isboxed) ...[
                      IconButton(
                        icon: trailingIcon!,
                        onPressed: onPressed,
                      ),
                    ],
                  ],
                ),
                if (child != null) ...[
                  SizedBox(height: 4),
                  child!,
                ],
              ],
            ),
          ),
          SizedBox(
            height: 4,
          )
        ],
      ),
    );
  }
}
