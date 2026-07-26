import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';
import '../pages/video_reels_page.dart';

const videosPostersList = [
  "https://scontent-man2-1.xx.fbcdn.net/v/t15.5256-10/650145143_1613757569913974_3881457024612799000_n.jpg?stp=dst-jpg_s720x720_tt6&_nc_cat=105&ccb=1-7&_nc_sid=a7ce7f&_nc_eui2=AeH1vUTo9fDV2u1UE-pCClGy3KwhcKA_kXvcrCFwoD-Re2t3MXxmHMqwwlSaZWLkLrb-u9Bv-5KvT-N79mRx5C79&_nc_ohc=kAR9xaO9X2YQ7kNvwGQK2q7&_nc_oc=AdrwXjvKVygjSB7RSEK-PEoZa2MKu6HcbIzNiNopj37lBObMWLbzOC07V3iJWIi3sBA&_nc_zt=23&_nc_ht=scontent-man2-1.xx&edm=AJfPMC4EAAAA&_nc_gid=nzPeMmMYViqwhYfjyEq25w&_nc_tpa=Q5bMBQG0PoNeYLkIXq9NV4srHT3j-nXlDzkV5FYBsUBWb2uNt9RkIthzxauK1txAdx6BbMepKCMt82FJ&oh=00_Afwc1NMPDZMkITXFkGHdyoODuyaGaZdjxjLLbgNETxUNvA&oe=69C3E322",
  "https://scontent-man2-1.xx.fbcdn.net/v/t15.5256-10/650056654_1467584755074727_1138957256494748974_n.jpg?stp=dst-jpg_s720x720_tt6&_nc_cat=101&ccb=1-7&_nc_sid=a7ce7f&_nc_eui2=AeHXCMfnjFEHRhR6fyBq0rHGUffTy-nbdnZR99PL6dt2dp7G-RCx6YyOgScm8rYWbCON5xLK2PWq3vxbpVvNtj8N&_nc_ohc=1ccwBo5AO_UQ7kNvwFQ0pID&_nc_oc=AdrJMOVv-l_zt3SkMil_Nkazebe95tZlr100jmUjY4_MtAzrp4GnafEgbTMuEMDVbmY&_nc_zt=23&_nc_ht=scontent-man2-1.xx&edm=AJfPMC4EAAAA&_nc_gid=TLRawSxgmyLk4kDJYnC-ig&_nc_tpa=Q5bMBQH0yj7kRk8g0pgJkGRNCl5WunE1Fgj9GYPFYQIzCaKeWBnh1x-Vv43a4dsRQPDJ98-tmsAxKAIt&oh=00_Afz4TnLCFlJ4qPILJtL5W07GgrnV4_IDSUq4bRO8RKepQg&oe=69C3FC16",
  "https://scontent-man2-1.xx.fbcdn.net/v/t15.5256-10/650211205_779709985214393_3876014258035384512_n.jpg?stp=dst-jpg_s720x720_tt6&_nc_cat=104&ccb=1-7&_nc_sid=5fad0e&_nc_eui2=AeHEJXnOBw4A6d3zM2OhGxireqyeYEzcAMZ6rJ5gTNwAxvCLBl8w3NsHliLTaJiAqLEdL8zFLjTrKe-u_k41xhbz&_nc_ohc=_D4H5l9UBiwQ7kNvwEzxhSl&_nc_oc=Adqi9DGYT4J9opeTs-vVxhtmwdd3K2e2gnU6hWIj58bzrzM3pMPU_dKWymmfo6_ZDJc&_nc_zt=23&_nc_ht=scontent-man2-1.xx&edm=AJfPMC4EAAAA&_nc_gid=_nmheI3ApE-bEKkSPYnf6A&_nc_tpa=Q5bMBQHaIbWh3sgnNjkNhonhAzF_ynMrlYEr1-4przJLxTak9BHUyKHiEfNYZeLr_7Pmnw_3gZ98T9WK&oh=00_Afx-B6JfhYHGHVRITmzRXYsjR1FYyQeNZ2pW_OQ4IDhjJQ&oe=69C402A9",
  "https://scontent-man2-1.xx.fbcdn.net/v/t15.5256-10/647747672_1260421428764228_1508966393318375089_n.jpg?stp=dst-jpg_s720x720_tt6&_nc_cat=108&ccb=1-7&_nc_sid=a7ce7f&_nc_eui2=AeEk7jV32O1q8KgyPTt_JttR5HiGc0PbmefkeIZzQ9uZ53F-ZZd8e-ZieYtDDgt40xBv3bMKQ0V80FSwOXaF73Vc&_nc_ohc=91hMqHXmuAcQ7kNvwGPwIgA&_nc_oc=Adp8fT3LlZ2MdNKyqVe8oLbJVsgRVftP4iWfNBiH2GF8IRe8EQnMPp6b1-GxrMqgHxM&_nc_zt=23&_nc_ht=scontent-man2-1.xx&edm=AJfPMC4EAAAA&_nc_gid=XYtVzcCArvCl-iLOKtmIBw&_nc_tpa=Q5bMBQGWRjZja8nXRHtMmNklSBDbxc_1NRv8avB_aU7b3chOG4UiCqZsK7ZUk16kH8WtYfpjQ2CoAfZR&oh=00_AfwaHSjL2J1_O0LgSQ20LKD92k_bGz5Tu1vpi7ieplJvxQ&oe=69C3FC07",
  "https://scontent-man2-1.xx.fbcdn.net/v/t15.5256-10/649909871_2109093646552609_750169383340442603_n.jpg?stp=dst-jpg_s720x720_tt6&_nc_cat=104&ccb=1-7&_nc_sid=a7ce7f&_nc_eui2=AeFY_odzFNxhX1E1gzOXpEQAKLOFZfX1I_Mos4Vl9fUj8ziH-7oC9kKgqMCI0r0DDRwdBw2-93EGYoBoNgbI6blC&_nc_ohc=X7XC5f696yUQ7kNvwGjSD34&_nc_oc=AdpAsLBtGsiMuK7neiupWsxSRJPeaakwOezrNlyi7rz5pk2lOM2gTDVQGjw0Jp7819Y&_nc_zt=23&_nc_ht=scontent-man2-1.xx&edm=AJfPMC4EAAAA&_nc_gid=lhUs8bECdaU1ZICVObF9cQ&_nc_tpa=Q5bMBQH8uY4V3In51LKvH4wvRPn6Cso8AhwVoW3dZkZfCLgyzwK4iCzCecGpBI5oP8CUMPHR5m4dEEmQ&oh=00_AfzKUIudkR5oSGc2XzqCbYYlXWUv88h5SjN0YDRPtJ5hPg&oe=69C3FE1B",
  "https://scontent-man2-1.xx.fbcdn.net/v/t15.5256-10/646746042_1243868311226897_8689755751704098556_n.jpg?stp=dst-jpg_s720x720_tt6&_nc_cat=110&ccb=1-7&_nc_sid=d2b52d&_nc_eui2=AeH4KPxq2oiB1AuFngrQtc2FM2tYPxwae_sza1g_HBp7-xvFwl5G1Rcq3T2FIIjWBySqJ8THPp-Ep48bf1vWAz3Z&_nc_ohc=cKlMZAz6hy8Q7kNvwFWq4zB&_nc_oc=AdkuElhbCOiC8_f3vMDHaN1e2NStQuTd-yRDHVYAwad1LflcSUSHNbXQnN9t_5o_SJM&_nc_zt=23&_nc_ht=scontent-man2-1.xx&edm=AJfPMC4EAAAA&_nc_gid=Pe2gBGmmQ1_rATioHHmGmQ&_nc_tpa=Q5bMBQHbseDR7Bt6ih-MbGjUEcqNEBMeBCyY8ICBBEr07LHZQMbQY08cXeWVzryEa3Ti6WGJiR4n4qxk&oh=00_AfxPMD_2UkuxBW1pVt1wwJx0VJ09YWVkbqxM2sKViICMxA&oe=69BE9A79",
];

class VideosSection extends StatelessWidget {
  final List<String> videosPostersList;

  const VideosSection({super.key, required this.videosPostersList});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('health_videos'.tr(), style: AppStyles.h2),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoReelsPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'see_all'.tr(),
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.darkTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.darkTeal,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: videosPostersList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoReelsPage(initialIndex: index),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryTeal.withValues(alpha: 0.3),
                        AppColors.primaryPurple.withValues(alpha: 0.3),
                      ],
                    ),
                    image: DecorationImage(
                      image: NetworkImage(videosPostersList[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                      // Play button
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: AppColors.primaryTeal,
                            size: 32,
                          ),
                        ),
                      ),
                      // Title at bottom
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'health_tip'.tr(args: [(index + 1).toString()]),
                              style: AppStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.visibility,
                                  size: 12,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'views_count'.tr(
                                    args: [((index + 1) * 1200).toString()],
                                  ),
                                  style: AppStyles.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
