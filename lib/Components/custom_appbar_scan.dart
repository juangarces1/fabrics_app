import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constans.dart';
import '../../../sizeconfig.dart';

class CustomAppBarScan extends StatelessWidget implements PreferredSizeWidget {
  final Function? press;
  final Widget titulo;
  final List<Widget>? actions;
  final AssetImage? image;

  const CustomAppBarScan({
    super.key,
    this.press,
    required this.titulo,
    this.actions,
    this.image,
  });

  @override
  Size get preferredSize => const Size.fromHeight(75);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: kGradientHome,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(16),
          vertical: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            if (press != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: press as void Function()?,
                  icon: SvgPicture.asset(
                    "assets/Back ICon.svg",
                    height: 14,
                    color: kPrimaryColor,
                  ),
                ),
              ),

            // Title Badge
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                // decoration: BoxDecoration(
                //   color: Colors.white.withValues(alpha: 0.15),
                //   borderRadius: BorderRadius.circular(16),
                //   border: Border.all(
                //     color: Colors.white.withValues(alpha: 0.2),
                //     width: 1.5,
                //   ),
                // ),
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: titulo),
                ),
              ),
            ),

            // Actions or Image
            if (actions != null)
              ...actions!
            else if (image != null)
              Opacity(
                opacity: 0.9,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    image: DecorationImage(image: image!, fit: BoxFit.cover),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
