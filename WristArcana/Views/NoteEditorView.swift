//
//  NoteEditorView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/3/25.
//

import SwiftUI

struct NoteEditorView: View {
    // MARK: - Properties

    @Binding var note: String
    let onSave: () -> Void
    let onCancel: () -> Void

    @State private var localNote: String = ""

    // MARK: - Computed Properties

    var remainingCharacters: Int {
        NoteInputSanitizer.remainingCharacters(self.localNote)
    }

    var isSaveDisabled: Bool {
        !NoteInputSanitizer.isValid(self.localNote)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Character counter
                Text("\(self.remainingCharacters) characters remaining")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                // Text input
                TextField("Add your reflection...", text: self.$localNote, axis: .vertical)
                    .lineLimit(5 ... 10)
                    .textInputAutocapitalization(.sentences)
                    .onChange(of: self.localNote) { _, newValue in
                        // Enforce character limit in real-time
                        if newValue.count > NoteInputSanitizer.maxCharacters {
                            self.localNote = String(newValue.prefix(NoteInputSanitizer.maxCharacters))
                        }
                    }

                Spacer()
            }
            .padding()
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.onCancel()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        self.note = self.localNote
                        self.onSave()
                    }
                    .disabled(self.isSaveDisabled)
                }
            }
            .onAppear {
                self.localNote = self.note
            }
        }
    }
}

#Preview {
    NoteEditorView(
        note: .constant(""),
        onSave: {},
        onCancel: {}
    )
}
