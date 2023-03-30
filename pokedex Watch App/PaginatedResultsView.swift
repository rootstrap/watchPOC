//
//  PaginatedResultsView.swift
//  pokedex Watch App
//
//  Created by Daniel Parra on 2/7/23.
//

import SwiftUI
import PokemonAPI

struct PaginatedResultsView: View {
    @EnvironmentObject var pokemonAPI: PokemonAPI
    @State var error: Error?
    
    /// The current pagedObject returned from the paginated web service call.
    @State var pagedObject: PKMPagedObject<PKMPokemon>?
    @State var pageIndex = 0
    
    
    var body: some View {
      NavigationStack {
        ScrollView {
          Spacer()
          mainContent
            .toolbar {
              ToolbarItemGroup(placement: .primaryAction) {
                menu
              }
            }
            .task {
              await fetchPokemon()
            }
        }
      }
    }

    var mainContent: some View {
        VStack {
            if let error = error {
                Text("An error occurred: \(error.localizedDescription)")
            }
            else if let pagedObject = pagedObject,
                    let pokemonResults = pagedObject.results as? [PKMNamedAPIResource<PKMPokemon>] {
                Group {
                    ForEach(pokemonResults, id: \.url) { pokemon in
                      let pokemonName = pokemon.name?.capitalized ?? "Unknown Pokemon"
                      NavigationLink {
                        PokemonDetailView(imageURL: pokemon.url?.pokemonIconURL, pokemonName: pokemonName)
                      } label: {
                        HStack {
                            Text(pokemonName)
                            AsyncImage(url: pokemon.url?.pokemonIconURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Image(systemName: "photo.circle.fill")
                            }
                            .frame(width: 30, height: 30)
                        }

                      }
                    }
                }
            }
        }
    }
    
    var menu: some View {
        VStack {
            pagePicker
                .disabled(pagedObject?.pages ?? 0 <= 1)
            HStack {
                Button(action: {
                    guard let pagedObject = pagedObject else { return }
                    Task { await fetchPokemon(paginationState: .continuing(pagedObject, .first)) }
                }) {
                    Image.first
                }
                .disabled(pagedObject?.hasPrevious == false)
                
                Spacer()
                
                Button(action: {
                    guard let pagedObject = pagedObject else { return }
                    Task { await fetchPokemon(paginationState: .continuing(pagedObject, .previous)) }
                }) {
                    Image.left
                }
                .disabled(pagedObject?.hasPrevious == false)
                
                Spacer()
                
                Button(action: {
                    guard let pagedObject = pagedObject else { return }
                    Task { await fetchPokemon(paginationState: .continuing(pagedObject, .next)) }
                }) {
                    Image.right
                }
                .disabled(pagedObject?.hasNext == false)
                
                Spacer()
                
                Button(action: {
                    guard let pagedObject = pagedObject else { return }
                    Task { await fetchPokemon(paginationState: .continuing(pagedObject, .last)) }
                }) {
                    Image.last
                }
                .disabled(pagedObject?.hasNext == false)
            }
        }
    }
    
    
    var pagePicker: some View {
        NavigationLink("Page \(pageIndex + 1)") {
            PageSelectView(pages: pagedObject?.pages ?? 0, pageIndex: $pageIndex)
                .onChange(of: pageIndex) { index in
                    guard let pagedObject = pagedObject else { return }
                    Task { await fetchPokemon(paginationState: .continuing(pagedObject, .page(index))) }
                }
        }
    }
    
    
    
    // MARK: - Data
    
    func fetchPokemon(paginationState: PaginationState<PKMPokemon> = .initial(pageLimit: 20)) async {
        do {
            pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(paginationState: paginationState)
            pageIndex = pagedObject?.currentPage ?? 0
        }
        catch {
            self.error = error
        }
    }
}

extension String {
  var pokemonIconURL: URL? {
    let url = dropLast().replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon/", with: "")
    return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(url).png")
  }
}


struct PaginatedResultsWatchView_Previews: PreviewProvider {
    static var previews: some View {
        PaginatedResultsView()
    }
}

extension BidirectionalCollection {
    var elementBeforeLast: Element? {
        return dropLast().last
    }
}
