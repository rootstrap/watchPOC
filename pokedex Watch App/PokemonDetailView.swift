//
//  PokemonDetailView.swift
//  pokedex Watch App
//
//  Created by German on 30/3/23.
//

import SwiftUI
import PokemonAPI

internal struct PokemonDetailView: View {
  @State var imageURL: URL?
  @State var pokemonName: String = ""
  @Environment(\.presentationMode) var presentation

  var body: some View {
    VStack(spacing: 10) {
      ZStack {
        Circle()
          .fill(Color.white)
          .shadow(color: .teal, radius: 5)
        AsyncImage(url: imageURL) { iamge in
          iamge
            .shadow(radius: 5)
            .frame(width: 50, height: 50)
        } placeholder: {
          Image(systemName: "icloud.and.arrow.down")
            .foregroundColor(.secondary)
        }
      }
      Text("\(pokemonName)")
        .foregroundColor(.teal)
      Button("Got it!") {
        presentation.wrappedValue.dismiss()
      }
      .accessibilityHint("Tap to close")
    }
  }
}

internal struct PokemonDetailView_Previews: PreviewProvider {
  static var previews: some View {
    PokemonDetailView(imageURL: URL(string: ""), pokemonName: "Pikachu")
  }
}

