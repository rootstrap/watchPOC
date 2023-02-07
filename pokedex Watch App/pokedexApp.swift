//
//  pokedexApp.swift
//  pokedex Watch App
//
//  Created by Daniel Parra on 1/24/23.
//

import SwiftUI
import PokemonAPI

@main
struct pokedex_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            let pokemonAPI = PokemonAPI()
            NavigationView {
                PaginatedResultsView()
                    .environmentObject(pokemonAPI)
            }
        }
    }
}
