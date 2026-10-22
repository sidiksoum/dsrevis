import 'package:country_picker/country_picker.dart';
import 'package:dsrevis/core/constants/app_colors.dart';
import 'package:dsrevis/features/shared/data/sample_data.dart';
import 'package:dsrevis/core/services/firebase_service.dart';
import 'package:flutter/material.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key, required this.onDone, required this.onRegister});

  final VoidCallback onDone;
  final ValueChanged<AppUser> onRegister;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _customAntenneController =
      TextEditingController();

  String _selectedCountryName = "Côte d'Ivoire";
  String _selectedCountryFlag = "🇨🇮";

  // Initialisation à null pour afficher les placeholders
  String? _selectedAntenne;
  String? _selectedLevel;
  String? _selectedFiliere;
  bool _obscurePassword = true;

  final List<String> _antennes = const [
    "Antenne Bouaké",
    "Antenne Abidjan",
    "Antenne Aboisso",
    "Antenne Abengourou",
    "Antenne Agboville",
    "Antenne Daloa",
    "Antenne Korhogo",
    "Antenne Man",
    "Autre",
  ];

  // Listes dynamiques récupérées du Cloud
  List<String> _levels = [];
  List<Map<String, dynamic>> _rawFilieres = [];
  List<String> _filieres = [];

  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLiveAcademicData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _customAntenneController.dispose();
    super.dispose();
  }

  void _showCountryPickerModal() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 520,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        inputDecoration: InputDecoration(
          labelText: "Rechercher un pays",
          hintText: "Tapez le nom ou le code...",
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        searchTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountryName = country.nameLocalized ?? country.name;
          _selectedCountryFlag = country.flagEmoji;
        });
      },
    );
  }

  void _updateFilteredFilieres(String selectedLevel) {
    final filtered = _rawFilieres
        .where((f) {
          final List<dynamic> years = f['years'] ?? [];
          return years.isEmpty || years.contains(selectedLevel);
        })
        .map((f) => f['name'] as String)
        .toList();

    setState(() {
      _filieres = filtered;
      // Re-vérifier si la filière sélectionnée est toujours valide dans le nouveau niveau
      if (_filieres.isNotEmpty) {
        if (_selectedFiliere != null && !_filieres.contains(_selectedFiliere)) {
          _selectedFiliere = null;
        }
      } else {
        _selectedFiliere = null;
      }
    });
  }

  Future<void> _fetchLiveAcademicData() async {
    try {
      final firebaseService = FirebaseService();
      final fetchedLevels = await firebaseService.fetchLiveLevelsFromServer();
      final fetchedFilieres = await firebaseService
          .fetchLiveFilieresWithYearsFromServer();

      if (mounted) {
        setState(() {
          _levels = fetchedLevels;
          _rawFilieres = fetchedFilieres;
          _isInitLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final antenneValue = _selectedAntenne == "Autre"
        ? _customAntenneController.text.trim()
        : _selectedAntenne!;

    try {
      final firebaseService = FirebaseService();
      final newUser = await firebaseService.registerStudent(
        name: name,
        email: email,
        password: password,
        level: _selectedLevel!,
        filiere: _selectedFiliere!,
        country: _selectedCountryName,
        antenne: antenneValue,
      );

      if (newUser != null && mounted) {
        widget.onRegister(newUser);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Compte créé avec succès !"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Échec de la création : $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isInitLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    "Chargement des filières INFAS...",
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.text,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Créer un compte",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Inscription Étudiant",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                validator: (val) => val == null || val.isEmpty
                                    ? "Nom requis"
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: "Nom complet",
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) =>
                                    val == null || !val.contains("@")
                                    ? "Email invalide"
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: "Adresse e-mail",
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: (val) =>
                                    val == null || val.length < 6
                                    ? "6 caractères minimum"
                                    : null,
                                decoration: InputDecoration(
                                  labelText: "Mot de passe",
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.muted,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.muted,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Sélecteur de pays avec package country_picker et drapeau
                              TextFormField(
                                key: ValueKey(
                                  "signup_country_$_selectedCountryName",
                                ),
                                initialValue:
                                    "$_selectedCountryFlag  $_selectedCountryName",
                                readOnly: true,
                                onTap: _showCountryPickerModal,
                                decoration: const InputDecoration(
                                  labelText: "Pays de résidence",
                                  prefixIcon: Icon(
                                    Icons.public_rounded,
                                    color: AppColors.muted,
                                  ),
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Menu déroulant pour l'Antenne / Ville
                              DropdownButtonFormField<String>(
                                value: _selectedAntenne,
                                isExpanded: true,
                                hint: const Text(
                                  "Sélectionnez votre antenne ou ville",
                                ),
                                validator: (val) => val == null
                                    ? "Veuillez sélectionner une antenne"
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: "Antenne ou ville",
                                  prefixIcon: Icon(
                                    Icons.location_city_rounded,
                                    color: AppColors.muted,
                                  ),
                                ),
                                items: _antennes.map((String ant) {
                                  return DropdownMenuItem<String>(
                                    value: ant,
                                    child: Text(ant),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedAntenne = val;
                                    });
                                  }
                                },
                              ),
                              if (_selectedAntenne == "Autre") ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _customAntenneController,
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty
                                      ? "Veuillez saisir votre antenne ou ville"
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText:
                                        "Saisissez votre antenne ou ville",
                                    prefixIcon: Icon(
                                      Icons.edit_location_alt_outlined,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),

                              // Menu déroulant dynamique pour le Niveau d'études
                              DropdownButtonFormField<String>(
                                value: _selectedLevel,
                                isExpanded: true,
                                hint: const Text(
                                  "Sélectionnez votre niveau d'études",
                                ),
                                validator: (val) => val == null
                                    ? "Veuillez sélectionner votre niveau"
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: "Niveau d'études",
                                  prefixIcon: Icon(
                                    Icons.school_outlined,
                                    color: AppColors.muted,
                                  ),
                                ),
                                items: _levels.map((String level) {
                                  return DropdownMenuItem<String>(
                                    value: level,
                                    child: Text(level),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedLevel = val;
                                      _updateFilteredFilieres(val);
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),

                              // Menu déroulant dynamique pour les Filières
                              DropdownButtonFormField<String>(
                                value: _selectedFiliere,
                                isExpanded: true,
                                hint: const Text("Sélectionnez votre filière"),
                                validator: (val) => val == null
                                    ? "Veuillez sélectionner une filière"
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: "Filière",
                                  prefixIcon: Icon(
                                    Icons.medical_services_outlined,
                                    color: AppColors.muted,
                                  ),
                                ),
                                items: _filieres.map((String filiere) {
                                  return DropdownMenuItem<String>(
                                    value: filiere,
                                    child: Text(filiere),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedFiliere = val);
                                  }
                                },
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _handleRegister,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text("Créer mon compte"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
