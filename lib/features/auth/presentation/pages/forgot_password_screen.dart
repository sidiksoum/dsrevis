import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/presentation/widgets/animated_logo.dart';
import '../../../../core/services/firebase_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.onPasswordResetSuccess,
  });

  final ValueChanged<String> onPasswordResetSuccess;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEmailVerified = false;
  String? _studentName;
  String? _verifiedEmail;

  bool _isCheckingEmail = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Étape 1 : Vérification de l'existence de l'email
  void _handleVerifyEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Veuillez saisir votre adresse email.";
      });
      return;
    }

    setState(() {
      _isCheckingEmail = true;
      _errorMessage = null;
    });

    try {
      final exists = await FirebaseService().checkEmailExists(email);
      if (!exists) {
        setState(() {
          _errorMessage = "Aucun compte étudiant trouvé avec cette adresse email.";
        });
      } else {
        final name = await FirebaseService().getUserNameByEmail(email);
        setState(() {
          _isEmailVerified = true;
          _studentName = name ?? "Étudiant";
          _verifiedEmail = email;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur est survenue lors de la vérification. Vérifiez votre connexion.";
      });
    } finally {
      if (mounted) setState(() => _isCheckingEmail = false);
    }
  }

  // Étape 2 : Réinitialisation du mot de passe
  void _handleResetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() {
        _errorMessage = "Veuillez remplir tous les champs de mot de passe.";
      });
      return;
    }

    if (newPass.length < 6) {
      setState(() {
        _errorMessage = "Le mot de passe doit comporter au moins 6 caractères.";
      });
      return;
    }

    if (newPass != confirmPass) {
      setState(() {
        _errorMessage = "Les deux mots de passe ne correspondent pas.";
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final success = await FirebaseService().resetStudentPassword(
        email: _verifiedEmail!,
        newPassword: newPass,
      );

      if (success) {
        if (!mounted) return;
        _showSuccessDialog();
      } else {
        setState(() {
          _errorMessage = "Impossible de réinitialiser le mot de passe. Veuillez réessayer.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur est survenue lors de l'enregistrement.";
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('Succès !', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Votre mot de passe a été modifié avec succès. Vous pouvez maintenant vous connecter avec vos nouveaux identifiants.',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Ferme le dialogue
              Navigator.of(context).pop(); // Retourne à l'écran de login
              widget.onPasswordResetSuccess(_verifiedEmail!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Se connecter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // En-tête Gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: 12,
              ),
              child: Column(
                children: [
                  // Barre de navigation supérieure
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Retour',
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Récupération de compte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const AnimatedLogo(size: 85),
                  const SizedBox(height: 12),
                  const Text(
                    'D.S REVIS',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Carte principale
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEmailVerified
                                ? 'Nouveau mot de passe'
                                : 'Mot de passe oublié ?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isEmailVerified
                                ? 'Créez un nouveau mot de passe sécurisé pour vous connecter.'
                                : 'Entrez votre adresse email pour vérifier votre compte étudiant.',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Message d'erreur
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.error.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Phase 1 : Saisie de l'email
                          if (!_isEmailVerified) ...[
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Adresse email',
                                hintText: 'ex: etudiant@gmail.com',
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.muted),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isCheckingEmail ? null : _handleVerifyEmail,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _isCheckingEmail
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text('Vérifier mon compte', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],

                          // Phase 2 : Définition du nouveau mot de passe
                          if (_isEmailVerified) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.successLight.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.success.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Compte trouvé : $_studentName',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        Text(
                                          '$_verifiedEmail',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Champ Nouveau mot de passe
                            TextField(
                              controller: _newPasswordController,
                              obscureText: _obscureNewPassword,
                              decoration: InputDecoration(
                                labelText: 'Nouveau mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.muted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureNewPassword = !_obscureNewPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Champ Confirmation mot de passe
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirmer le mot de passe',
                                prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.muted),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.muted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _handleResetPassword,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Enregistrer le nouveau mot de passe',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded, size: 16),
                              label: const Text('Retour à la connexion'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
