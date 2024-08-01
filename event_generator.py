import random
import csv

# Set the random seed for reproducibility
random.seed(42)

# List of movies with their genres
movies = [
    ("The Shawshank Redemption", "Drama"),
    ("The Godfather", "Crime"),
    ("The Dark Knight", "Action"),
    ("Pulp Fiction", "Crime"),
    ("The Lord of the Rings: The Return of the King", "Fantasy"),
    ("Forrest Gump", "Romance"),
    ("Inception", "Sci-Fi"),
    ("The Matrix", "Sci-Fi"),
    ("The Silence of the Lambs", "Thriller"),
    ("Gladiator", "Action"),
    ("Titanic", "Romance"),
    ("Schindler’s List", "Drama"),
    ("The Lion King", "Animation"),
    ("Fight Club", "Drama"),
    ("Interstellar", "Sci-Fi"),
    ("The Green Mile", "Fantasy"),
    ("Braveheart", "Action"),
    ("Goodfellas", "Crime"),
    ("The Lord of the Rings: The Fellowship of the Ring", "Fantasy"),
    ("Star Wars: Episode IV - A New Hope", "Sci-Fi"),
    ("The Lord of the Rings: The Two Towers", "Fantasy"),
    ("Jurassic Park", "Sci-Fi"),
    ("The Godfather: Part II", "Crime"),
    ("The Departed", "Crime"),
    ("Django Unchained", "Western"),
    ("The Prestige", "Mystery"),
    ("The Lion King", "Animation"),
    ("The Usual Suspects", "Crime"),
    ("Saving Private Ryan", "War"),
    ("American History X", "Drama"),
    ("The Dark Knight Rises", "Action"),
    ("Inglourious Basterds", "War"),
    ("Se7en", "Thriller"),
    ("Whiplash", "Drama"),
    ("The Social Network", "Biography"),
    ("Avengers: Endgame", "Action"),
    ("The Avengers", "Action"),
    ("Shutter Island", "Thriller"),
    ("The Wolf of Wall Street", "Biography"),
    ("Mad Max: Fury Road", "Action"),
    ("Black Panther", "Action"),
    ("Wonder Woman", "Action"),
    ("Spider-Man: Into the Spider-Verse", "Animation"),
    ("Coco", "Animation"),
    ("Frozen", "Animation"),
    ("Moana", "Animation"),
    ("Toy Story", "Animation"),
    ("Toy Story 3", "Animation"),
    ("Toy Story 4", "Animation"),
    ("Finding Nemo", "Animation"),
    ("The Incredibles", "Animation"),
    ("Inside Out", "Animation"),
    ("Up", "Animation"),
    ("WALL·E", "Animation"),
    ("Ratatouille", "Animation"),
    ("Monsters, Inc.", "Animation"),
    ("A Bug's Life", "Animation"),
    ("Zootopia", "Animation"),
    ("The Lego Movie", "Animation"),
    ("The Simpsons Movie", "Animation"),
    ("Shrek", "Animation"),
    ("Shrek 2", "Animation"),
    ("Despicable Me", "Animation"),
    ("Despicable Me 2", "Animation"),
    ("Minions", "Animation"),
    ("How to Train Your Dragon", "Animation"),
    ("Kung Fu Panda", "Animation"),
    ("Kung Fu Panda 2", "Animation"),
    ("Kung Fu Panda 3", "Animation"),
    ("Madagascar", "Animation"),
    ("Madagascar: Escape 2 Africa", "Animation"),
    ("Madagascar 3: Europe’s Most Wanted", "Animation"),
    ("Ice Age", "Animation"),
    ("Ice Age: The Meltdown", "Animation"),
    ("Ice Age: Dawn of the Dinosaurs", "Animation"),
    ("Ice Age: Continental Drift", "Animation"),
    ("Ice Age: Collision Course", "Animation"),
    ("Hotel Transylvania", "Animation"),
    ("Hotel Transylvania 2", "Animation"),
    ("Hotel Transylvania 3: Summer Vacation", "Animation"),
    ("The Secret Life of Pets", "Animation"),
    ("The Secret Life of Pets 2", "Animation"),
    ("Sing", "Animation"),
    ("Sing 2", "Animation"),
    ("Tangled", "Animation"),
    ("Big Hero 6", "Animation"),
    ("The Jungle Book", "Animation"),
    ("The Little Mermaid", "Animation"),
    ("Beauty and the Beast", "Animation"),
    ("Aladdin", "Animation"),
    ("Mulan", "Animation"),
    ("Pocahontas", "Animation"),
    ("Hercules", "Animation"),
    ("Tarzan", "Animation"),
    ("Atlantis: The Lost Empire", "Animation"),
    ("Lilo & Stitch", "Animation"),
    ("The Emperor's New Groove", "Animation"),
    ("Treasure Planet", "Animation"),
    ("Brother Bear", "Animation"),
    ("Home on the Range", "Animation"),
    ("Chicken Little", "Animation"),
    ("Meet the Robinsons", "Animation"),
    ("Bolt", "Animation"),
    ("The Princess and the Frog", "Animation"),
    ("Winnie the Pooh", "Animation"),
    ("Frozen II", "Animation"),
    ("Ralph Breaks the Internet", "Animation"),
    ("Wreck-It Ralph", "Animation"),
    ("Zootropolis", "Animation")
]

# Number of records to generate
num_records = 10**6  # 1 million

# Generate random user data
user_ids = [random.randint(1, 1000000) for _ in range(num_records)]
movie_choices = [random.choice(movies) for _ in range(num_records)]
streaming_hours = [random.uniform(0.5, 10.0) for _ in range(num_records)]
genders = ['Male', 'Female', 'Other']
user_genders = [random.choice(genders) for _ in range(num_records)]
user_ages = [random.randint(10, 70) for _ in range(num_records)]
devices = ['Smartphone', 'Tablet', 'Laptop', 'Desktop', 'Smart TV']
streaming_devices = [random.choice(devices) for _ in range(num_records)]

# Create a CSV file
with open('movie_streaming_data.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['user_id', 'movie_name', 'streaming_hours', 'genre', 'gender', 'age', 'device'])
    for i in range(num_records):
        writer.writerow([user_ids[i], movie_choices[i][0], streaming_hours[i], movie_choices[i][1], user_genders[i], user_ages[i], streaming_devices[i]])

print("Data generation complete. CSV file saved.")
