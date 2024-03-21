//
//  ViewController.swift
//  moviesTable
//
//  Created by Jurymar Colmenares on 18/03/24.
//

import UIKit

struct Movie: Decodable {
    let title: String
    let posterPath: String
    let overview: String
    let releaseDate: String
    
    private enum CodingKeys: String, CodingKey {
        case title
        case posterPath = "poster_path"
        case overview
        case releaseDate = "release_date"
    }
}

struct MovieResult: Decodable {
    let results: [Movie]
}

class ViewController: UIViewController {
    
    var tableView: UITableView!
    var movies = [Movie]()
    var filteredMovies = [Movie]()
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar la tabla de vista
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        view.addSubview(tableView)
        
        // Configurar el searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Buscar películas"
        view.addSubview(searchBar)
        
        // Configurar el título de la barra de navegación
        self.title = "Populares"
        
        // Cambiar el color de fondo de la barra de navegación
        navigationController?.navigationBar.barTintColor = UIColor.black // Puedes cambiar el color aquí
        
        // Llamar a la función addConstraints
        addConstraints()
        
        // Obtener los datos de la API
        fetchData()
    }
    
    func fetchData() {
        let apiKey = "d4849d0d8592036d63a3e615d5439c28"
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error al obtener los datos:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(MovieResult.self, from: data)
                self.movies = result.results
                self.filteredMovies = self.movies
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error al decodificar los datos:", error.localizedDescription)
            }
        }.resume()
    }
}

//UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        let movie = filteredMovies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }
}

//UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

//UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies.filter { movie in
                let titleContainsSearchText = movie.title.lowercased().contains(searchText.lowercased())
                let overviewContainsSearchText = movie.overview.lowercased().contains(searchText.lowercased())
                let releaseDateContainsSearchText = movie.releaseDate.lowercased().contains(searchText.lowercased())
                return titleContainsSearchText || overviewContainsSearchText || releaseDateContainsSearchText
            }
        }
        tableView.reloadData()
    }
}

//Auto Layout
extension ViewController {
    func addConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //arriba topAnchor
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            //izquierda - inicio leadingAnchor
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            //derecha - fin trailingAnchor
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //searchBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
            //abajo bottomAnchor
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//TableViewCell
class MovieTableViewCell: UITableViewCell {
    
    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        
        if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500/\(movie.posterPath)") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: posterURL) {
                    DispatchQueue.main.async {
                        self.posterImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
