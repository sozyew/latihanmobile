import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/ticket_controller.dart';
import '../widgets/video_bg.dart';
import '../widgets/ticket_card.dart';
import '../widgets/motion.dart';
import '../widgets/segmented_filter.dart';
import '../models/ticket_package.dart';
import '../theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<String> _categoryKeys = [
    'all',
    'grandstand',
    'walkabout',
    'hospitality',
  ];
  static const List<String> _categoryLabels = ['All', 'Stands', 'Walk', 'VIP'];
  // GETX: mengambil controller dengan Get.find
  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final ticketCtrl = Get.find<TicketController>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await homeCtrl.fetchWeatherAndAirQuality();
          ticketCtrl.loadTickets();
        },
        color: AppTheme.f1Red,
        backgroundColor: AppTheme.surfaceBg,
        child: SingleChildScrollView(
          controller: homeCtrl.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero (video + hitung mundur + cuaca), bergeser pelan saat scroll
              AnimatedBuilder(
                animation: homeCtrl.scrollController,
                child: const VideoBgHero(),
                builder: (context, child) {
                  final c = homeCtrl.scrollController;
                  final off = c.hasClients ? c.offset.clamp(0.0, 400.0) : 0.0;
                  return ClipRect(
                    child: Transform.translate(
                      offset: Offset(0, off * 0.25),
                      child: child,
                    ),
                  );
                },
              ),

              // 2. Judul section + jumlah pilihan
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  key: homeCtrl.carouselKey,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text(
                    'Pick Your Seat',
                    style: AppText.h2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // GETX: Obx memperbarui filter saat kategori berubah
              // 3. Filter geser
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() {
                    final idx = _categoryKeys
                        .indexOf(ticketCtrl.selectedCategory.value);
                    return SegmentedFilter(
                      labels: _categoryLabels,
                      selectedIndex: idx < 0 ? 0 : idx,
                      onChanged: (i) => ticketCtrl.setCategory(_categoryKeys[i]),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),

              // 4. Carousel tiket (kartu aktif membesar, tetangganya mengecil)
              SizedBox(
                height: 330,
                child: Obx(() {
                  final list = ticketCtrl.filteredTickets.toList();
                  final cat = ticketCtrl.selectedCategory.value;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: list.isEmpty
                        ? const Center(
                            key: ValueKey('empty'),
                            child: Text(
                              'No tickets in this category yet.',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          )
                        : _TicketCarousel(
                            key: ValueKey(cat),
                            items: list,
                            onOpen: (item) {
                              ticketCtrl.selectTicket(item);
                              Get.toNamed('/ticket-detail', arguments: item);
                            },
                          ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // 5. Jadwal race weekend (timeline)
              FadeSlideIn(
                delay: const Duration(milliseconds: 260),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSchedule(homeCtrl),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  // DATA STATIS: jadwal race weekend
  Widget _buildSchedule(HomeController homeCtrl) {
    const rows = [
      ['Fri 8 Oct', 'Practice 1 & 2', '17:30 & 21:00 SGT'],
      ['Sat 9 Oct', 'Practice 3 & Qualifying', '17:30 & 21:00 SGT'],
      ['Sun 10 Oct', 'Singapore Grand Prix · 62 laps', '20:00 SGT'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Race Weekend',
          style: AppText.h2,
        ),
        const SizedBox(height: 12),
        _buildWeatherStrip(homeCtrl),
        const SizedBox(height: 18),
        for (int i = 0; i < rows.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.f1Red,
                        ),
                      ),
                      if (i != rows.length - 1)
                        Expanded(
                          child: Container(
                            width: 1,
                            margin: const EdgeInsets.only(top: 6),
                            color: AppTheme.cardBorder,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: i == rows.length - 1 ? 0 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${rows[i][0]} · ${rows[i][1]}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rows[i][2],
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  // API + GETX: menampilkan data cuaca secara reaktif
  /// Cuaca trek, ditaruh ringkas di section Race Weekend (bukan di hero).
  Widget _buildWeatherStrip(HomeController homeCtrl) {
    return Obx(() {
      final loading = homeCtrl.isLoadingWeather.value;
      final w = homeCtrl.weather.value;
      final aq = homeCtrl.airQuality.value;

      final airNote = (aq != null &&
              !aq.qualityStatus.toLowerCase().contains('good'))
          ? ' · Air Quality: ${aq.qualityStatus}'
          : '';
      final text = loading
          ? 'Checking Marina Bay weather…'
          : 'Marina Bay · ${w?.temperature.toStringAsFixed(0) ?? '--'}° ${w?.description ?? ''}$airNote';

      final row = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny_rounded, size: 18, color: AppTheme.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text.trim(),
                style: AppText.caption.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!loading) ...[
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Live',
                style: TextStyle(
                  color: AppTheme.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );

      return loading ? Pulse(child: row) : row;
    });
  }
}

class _TicketCarousel extends StatefulWidget {
  final List<TicketPackage> items;
  final void Function(TicketPackage) onOpen;

  const _TicketCarousel({super.key, required this.items, required this.onOpen});

  @override
  State<_TicketCarousel> createState() => _TicketCarouselState();
}

class _TicketCarouselState extends State<_TicketCarousel> {
  late final PageController _controller =
      PageController(viewportFraction: 0.74);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 9),
      child: PageView.builder(
      controller: _controller,
      physics: const BouncingScrollPhysics(),
      padEnds: false,
      clipBehavior: Clip.none,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double page = 0;
            if (_controller.hasClients &&
                _controller.position.haveDimensions) {
              page = _controller.page ?? 0;
            }
            final d = (page - index).abs().clamp(0.0, 1.0);
            return Transform.scale(
              scale: 1 - 0.07 * d,
              alignment: Alignment.topCenter,
              child: Opacity(opacity: 1 - 0.25 * d, child: child),
            );
          },
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
              child: FadeSlideIn(
                key: ValueKey(item.id),
                delay: Duration(milliseconds: 60 * (index < 3 ? index : 3)),
                offsetY: 20,
                child: TicketCard(
                  ticket: item,
                  fillWidth: true,
                  heroTag: 'ticket-img-${item.id}',
                  onTap: () => widget.onOpen(item),
                  onMorePressed: () => widget.onOpen(item),
                ),
              ),
            ),
          ),
        );
      },
    ),
    );
  }
}
