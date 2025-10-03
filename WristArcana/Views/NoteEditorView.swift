//
//  NoteEditorView.swift
//  WristArcana
//
//  Created by OpenAI on 3/8/24.
//

import SwiftUI

struct NoteEditorView: View {
    @Binding var note: String
    let onSave: () -> Void
    let onCancel: () -> Void

    @State private var localNote: String = ""

    private var remainingCharacters: Int {
        NoteInputSanitizer.remainingCharacters(self.localNote)
    }

    private var isSaveDisabled: Bool {
        !NoteInputSanitizer.isValid(self.localNote)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("\(self.remainingCharacters) characters remaining")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                TextField("Add your reflection...", text: self.$localNote, axis: .vertical)
                    .lineLimit(5...10)
                    .textInputAutocapitalization(.sentences)
                    .onChange(of: self.localNote) { _, newValue in
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
    NoteEditorView(note: .constant("Sample note"), onSave: {}, onCancel: {})
}
