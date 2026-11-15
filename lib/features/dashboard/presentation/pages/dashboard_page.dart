import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../../core/session/account_session.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../quests/data/repositories/parsed_quest_repository.dart';
import '../../../quests/domain/engines/quest_engine.dart';
import '../../../quests/presentation/pages/quests_page.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/quest_section.dart';
import '../widgets/tactile_button.dart';

class DashboardPage extends StatefulWidget {
  final int initialNavIndex;
  final AccountSession accountSession;

  const DashboardPage({
    super.key,
    this.initialNavIndex = 0,
    required this.accountSession,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ParsedQuestRepository? _questRepository;
  QuestEngine? _questEngine;
  late int _currentNavIndex;

  bool _isLoading = true;
  String? _loadError;

  // List untuk menyimpan log UI
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialNavIndex;
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    try {
      // Langsung buat repo live tanpa data palsu (fixture)
      final repository = ParsedQuestRepository(
        accountSession: widget.accountSession,
      );

      if (!mounted) {
        repository.dispose();
        return;
      }

      final engine = QuestEngine(repository: repository)
        ..onLog = ((message, level) {
          debugPrint('[QuestEngine][$level] $message');
          if (!mounted) return;
          setState(() {
            _logs.add('[$level] $message');
            if (_logs.length > 4) _logs.removeAt(0); // Simpan 4 log terakhir agar rapi
          });
        });

      setState(() {
        _questRepository = repository;
        _questEngine = engine;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _questEngine?.dispose();
    _questRepository?.dispose();
    super.dispose();
  }

  // Logika pemilihan gambar Seele berdasarkan status
  String _getSeeleImage(QuestEngine? engine) {
    if (engine == null || !engine.isRunning) {
      return 'assets/images/seele_idle.webp'; // Tampil saat diam
    }

    // Cek apakah ada quest yang baru saja selesai (done)
    final hasDone = engine.runs.any((r) => r.completed);
    if (hasDone) {
      return 'assets/images/seele_done.webp'; // Tampil saat selesai
    }

    return 'assets/images/seele_work.webp'; // Tampil saat bekerja
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.accountSession,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 960;

            final username =
                widget.accountSession.accountInfo?.effectiveDisplayName ??
                'Guest';

            final questRepository = _questRepository;
            final questEngine = _questEngine;

            if (_isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (_loadError != null ||
                questRepository == null ||
                questEngine == null) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Gagal memuat quest: ${_loadError ?? "Repository tidak tersedia"}',
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: AppColor.background,
              bottomNavigationBar: isDesktop
                  ? null
                  : DashboardBottomNav(
                      currentIndex: _currentNavIndex,
                      onTap: (index) {
                        setState(() => _currentNavIndex = index);
                      },
                    ),
              body: Row(
                children: [
                  if (isDesktop)
                    DashboardSidebar(
                      accountSession: widget.accountSession,
                      selectedIndex: _currentNavIndex,
                      onDestinationSelected: (index) {
                        setState(() => _currentNavIndex = index);
                      },
                    ),

                  Expanded(
                    child: _currentNavIndex == 1
                        ? QuestsPage(
                            repository: questRepository,
                            engine: questEngine,
                            embedded: true,
                            onNavigate: (index) {
                              setState(() => _currentNavIndex = index);
                            },
                          )
                        : _currentNavIndex == 5
                        ? AccountPage(accountSession: widget.accountSession)
                        : SafeArea(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop
                                    ? AppSpacing.xl
                                    : AppSpacing.md,
                                vertical: AppSpacing.lg,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1100,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dashboard',
                                        style: const TextStyle(
                                          color: AppColor.textPrimary,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),

                                      const SizedBox(height: AppSpacing.xs),

                                      Text(
                                        'Welcome back, $username!',
                                        style: const TextStyle(
                                          color: AppColor.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(height: AppSpacing.lg),

                                      // ── Automation Control ─────────────
                                      Wrap(
                                        spacing: AppSpacing.sm,
                                        runSpacing: AppSpacing.sm,
                                        children: [
                                          TactileButton(
                                            label: 'Sync Quests',
                                            color: TactileColor.cyan,
                                            height: 44,
                                            icon: const Icon(
                                              Icons.sync_rounded,
                                              size: 18,
                                              color: AppColor.background,
                                            ),
                                            onPressed: () async {
                                              final repo = _questRepository;
                                              if (repo == null) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Menarik data quest dari Discord...',
                                                  ),
                                                ),
                                              );
                                              try {
                                                await repo.fetchAndSyncOnly();
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Quest berhasil disinkronisasi.',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Gagal sync: $e',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                          TactileButton(
                                            label: 'Start Automation',
                                            color: TactileColor.lime,
                                            height: 44,
                                            icon: const Icon(
                                              Icons.play_arrow_rounded,
                                              size: 18,
                                              color: AppColor.background,
                                            ),
                                            onPressed: () {
                                              final engine = _questEngine;
                                              if (engine == null) return;
                                              if (engine.isRunning) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Automation sedang berjalan.',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              engine.startAutomation();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Automation dimulai. Cek panel log di bawah.',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          TactileButton(
                                            label: 'Stop',
                                            color: TactileColor.surface,
                                            height: 44,
                                            icon: const Icon(
                                              Icons.stop_rounded,
                                              size: 18,
                                              color: AppColor.textPrimary,
                                            ),
                                            onPressed: () {
                                              _questEngine?.stop();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Automation dihentikan.',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: AppSpacing.md),

                                      // ── SEELE AUTOMATION CONSOLE ─────────────
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(AppSpacing.md),
                                        decoration: BoxDecoration(
                                          // Warna ungu gelap khas Dark Seele
                                          color: const Color(0xFF1A1124),
                                          borderRadius: BorderRadius.circular(AppRadius.lg),
                                          border: Border.all(
                                            // Border merah menyala khas Seele Vollerei
                                            color: const Color(0xFFE53935), 
                                            width: 2.0,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x33E53935), // Glow merah tipis
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Maskot Seele
                                            Image.asset(
                                              _getSeeleImage(questEngine),
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(width: AppSpacing.md),
                                            
                                            // Teks Log
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        questEngine.isRunning ? 'SEELE IS WORKING...' : 'SEELE IS RESTING',
                                                        style: const TextStyle(
                                                          color: Color(0xFFE53935),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: 1.5,
                                                        ),
                                                      ),
                                                      if (questEngine.isRunning)
                                                        const SizedBox(
                                                          width: 12, height: 12,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Color(0xFFE53935),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  if (_logs.isEmpty)
                                                    const Text(
                                                      '> Ready to dive into the Sea of Quanta...',
                                                      style: TextStyle(
                                                        color: AppColor.textMuted,
                                                        fontSize: 12,
                                                        fontFamily: 'monospace',
                                                      ),
                                                    )
                                                  else
                                                    ..._logs.map((log) => Padding(
                                                          padding: const EdgeInsets.only(bottom: 4),
                                                          child: Text(
                                                            '> ${log.replaceAll('[info]', '').replaceAll('[ok]', '').replaceAll('[progress]', '').trim()}',
                                                            style: const TextStyle(
                                                              color: AppColor.textPrimary,
                                                              fontSize: 12,
                                                              fontFamily: 'monospace',
                                                            ),
                                                          ),
                                                        )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: AppSpacing.xxl),

                                      QuestSection(
                                        repository: questRepository,
                                        onViewAll: () {
                                          setState(() {
                                            _currentNavIndex = 1;
                                          });
                                        },
                                      ),

                                      const SizedBox(height: AppSpacing.xxl),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}