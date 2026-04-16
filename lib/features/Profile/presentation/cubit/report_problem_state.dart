import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPORT PROBLEM STATE
// 
// Represents the state of problem report submission.
// Includes loading, success, and error states with server messages.
// ─────────────────────────────────────────────────────────────────────────────

abstract class ReportProblemState extends Equatable {
  const ReportProblemState();

  @override
  List<Object?> get props => [];
}

// ── Initial State ──────────────────────────────────────────────────────────
class ReportProblemInitial extends ReportProblemState {
  const ReportProblemInitial();
}

// ── Loading State ──────────────────────────────────────────────────────────
class ReportProblemLoading extends ReportProblemState {
  const ReportProblemLoading();
}

// ── Success State ──────────────────────────────────────────────────────────
/// Contains the success message from the server
class ReportProblemSuccess extends ReportProblemState {
  final String message;

  const ReportProblemSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Error State ────────────────────────────────────────────────────────────
/// Contains the error message from the server or failure
class ReportProblemError extends ReportProblemState {
  final String message;

  const ReportProblemError(this.message);

  @override
  List<Object?> get props => [message];
}
