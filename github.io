# IMDB
This is the project of IMDB Clone
<!DOCTYPE html>
<html>
<head>
  <title>IMDB Clone</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <!-- Header -->
  <header>
    <h1>IMDB Clone</h1>
  </header>

  <!-- Home Page -->
  <div class="container">
    <input type="text" id="searchInput" placeholder="Search for a movie...">
    <div id="searchResults"></div>
  </div>

  <!-- Movie Page (Modal) -->
  <div id="movieModal" class="modal">
    <div class="modal-content" id="movieModalContent">
      <!-- Movie details will be displayed here -->
    </div>
  </div>

  <!-- My Favourite Movies Page -->
  <div class="container">
    <h2>My Favourite Movies</h2>
    <ul id="favouritesList"></ul>
  </div>

  <script src="script.js"></script>
</body>
</html>

CSS Style
/* Reset some default styles */
body, h1, h2, h3, p, ul, li {
  margin: 0;
  padding: 0;
}

body {
  font-family: Arial, sans-serif;
  background-color: #f0f0f0;
  color: #333;
  line-height: 1.6;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

/* Header styles */
header {
  background-color: #007bff;
  color: #fff;
  padding: 10px;
  text-align: center;
}

header h1 {
  font-size: 24px;
}

/* Search styles */
#searchInput {
  width: 100%;
  padding: 10px;
  font-size: 16px;
  border: 2px solid #007bff;
  border-radius: 5px;
  margin-bottom: 10px;
}

/* Search results styles */
#searchResults {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  grid-gap: 20px;
}

#searchResults div {
  background-color: #fff;
  padding: 10px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

#searchResults img {
  max-width: 100%;
}

/* Movie details modal styles */
#movieModal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.8);
}

.modal-content {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background-color: #fff;
  padding: 20px;
  max-width: 600px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
}

.modal-content img {
  max-width: 100%;
  margin-bottom: 10px;
}

.modal-content h3 {
  font-size: 20px;
  margin-bottom: 10px;
}

.modal-content p {
  margin-bottom: 20px;
}

/* My Favourite Movies styles */
#favouritesList {
  list-style: none;
}

#favouritesList li {
  background-color: #fff;
  padding: 10px;
  margin-bottom: 10px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

#favouritesList li img {
  max-width: 100px;
  margin-right: 10px;
}

#favouritesList li button {
  background-color: #dc3545;
  color: #fff;
  padding: 5px 10px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

Javascript
// OMDB API URL and your API key
const API_KEY = 'YOUR_API_KEY';
const OMDB_API_URL = 'https://www.omdbapi.com/';

// Function to fetch movie data from OMDB API based on search query
async function searchMovies(query) {
  const response = await fetch(`${OMDB_API_URL}?apikey=${API_KEY}&s=${query}`);
  const data = await response.json();
  return data.Search || [];
}

// Function to display search results on the frontend
function displaySearchResults(results) {
  const searchResultsContainer = document.getElementById('searchResults');
  searchResultsContainer.innerHTML = '';

  results.forEach((movie) => {
    const movieItem = document.createElement('div');
    movieItem.innerHTML = `
      <h3 data-movie-id="${movie.imdbID}">${movie.Title}</h3>
      <img src="${movie.Poster}" alt="${movie.Title}">
      <button class="favouriteBtn" data-movie-id="${movie.imdbID}">Favourite</button>
    `;
    searchResultsContainer.appendChild(movieItem);
  });
}

// Function to add a movie to "My favourite movies" list
function addToFavourites(movieID) {
  const favouritesList = document.getElementById('favouritesList');
  const movie = document.querySelector(`[data-movie-id="${movieID}"]`);
  const clonedMovie = movie.cloneNode(true);

  // Check if the movie is already in the favourites list
  const existingMovie = favouritesList.querySelector(`[data-movie-id="${movieID}"]`);
  if (!existingMovie) {
    // Add remove button to the cloned movie
    const removeBtn = document.createElement('button');
    removeBtn.classList.add('removeBtn');
    removeBtn.textContent = 'Remove from favourites';
    clonedMovie.appendChild(removeBtn);

    // Add click event listener to the remove button
    removeBtn.addEventListener('click', () => {
      favouritesList.removeChild(clonedMovie);
      // Update local storage to remove the movie
      const favourites = JSON.parse(localStorage.getItem('favourites')) || [];
      const updatedFavourites = favourites.filter((id) => id !== movieID);
      localStorage.setItem('favourites', JSON.stringify(updatedFavourites));
    });

    favouritesList.appendChild(clonedMovie);
    // Update local storage to add the movie
    const favourites = JSON.parse(localStorage.getItem('favourites')) || [];
    favourites.push(movieID);
    localStorage.setItem('favourites', JSON.stringify(favourites));
  }
}

// Function to display more information about a movie (Movie Page)
async function showMovieDetails(movieID) {
  const response = await fetch(`${OMDB_API_URL}?apikey=${API_KEY}&i=${movieID}`);
  const data = await response.json();

  const movieModalContent = document.getElementById('movieModalContent');
  movieModalContent.innerHTML = `
    <h3>${data.Title}</h3>
    <img src="${data.Poster}" alt="${data.Title}">
    <p>${data.Plot}</p>
    <!-- Add more movie details as needed -->
  `;

  const movieModal = document.getElementById('movieModal');
  movieModal.style.display = 'block';
}

// Function to close the movie modal
function closeMovieModal() {
  const movieModal = document.getElementById('movieModal');
  movieModal.style.display = 'none';
}

// Event listener for search input
const searchInput = document.getElementById('searchInput');
searchInput.addEventListener('input', async (e) => {
  const query = e.target.value;
  const results = await searchMovies(query);
  displaySearchResults(results);
});

// Event delegation for "Favourite" button clicks in search results
document.addEventListener('click', (e) => {
  if (e.target.matches('.favouriteBtn')) {
    const movieID = e.target.dataset.movieId;
    addToFavourites(movieID);
  }
});

// Event delegation for "Movie Page" clicks in search results
document.addEventListener('click', (e) => {
  if (e.target.matches('h3')) {
    const movieID = e.target.dataset.movieId;
    showMovieDetails(movieID);
  }
});

// Event listener for closing the movie modal
document.addEventListener('click', (e) => {
  if (e.target.matches('.modal')) {
    closeMovieModal();
  }
});

// On page load, display favourite movies from local storage
document.addEventListener('DOMContentLoaded', () => {
  const favouritesList = document.getElementById('favouritesList');
  const favourites = JSON.parse(localStorage.getItem('favourites')) || [];

  favourites.forEach(async (movieID) => {
    const response = await fetch(`${OMDB_API_URL}?apikey=${API_KEY}&i=${movieID}`);
    const data = await response.json();

    const movieItem = document.createElement('li');
    movieItem.innerHTML = `
      <h3 data-movie-id="${data.imdbID}">${data.Title}</h3>
      <img src="${data.Poster}" alt="${data.Title}">
      <button class="removeBtn" data-movie-id="${data.imdbID}">Remove from favourites</button>
    `;

    favouritesList.appendChild(movieItem);

    // Add click event listener to the remove button
    const removeBtn = movieItem.querySelector('.removeBtn');
    removeBtn.addEventListener('click', () => {
      favouritesList.removeChild(movieItem);
      // Update local storage to remove the movie
      const updatedFavourites = favourites.filter((id) => id !== data.imdbID);
      localStorage.setItem('favourites', JSON.stringify(updatedFavourites));
    });
  });
});
