import requests
import httpx
import random
import csv
from datetime import datetime, timedelta

# Set the random seed for reproducibility
random.seed(42)

# List of movies with their genres
movies = [
    ("The Shawshank Redemption", "Drama", 1994, "Frank Darabont"),
    ("The Godfather", "Crime", 1972, "Francis Ford Coppola"),
    ("The Dark Knight", "Action", 2008, "Christopher Nolan"),
    ("Pulp Fiction", "Crime", 1994, "Quentin Tarantino"),
    ("The Lord of the Rings: The Return of the King", "Fantasy", 2003, "Peter Jackson"),
    ("Forrest Gump", "Romance", 1994, "Robert Zemeckis"),
    ("Inception", "Sci-Fi", 2010, "Christopher Nolan"),
    ("The Matrix", "Sci-Fi", 1999, "The Wachowskis"),
    ("The Silence of the Lambs", "Thriller", 1991, "Jonathan Demme"),
    ("Gladiator", "Action", 2000, "Ridley Scott"),
    ("Titanic", "Romance", 1997, "James Cameron"),
    ("Schindler’s List", "Drama", 1993, "Steven Spielberg"),
    ("The Lion King", "Animation", 1994, "Roger Allers and Rob Minkoff"),
    ("Fight Club", "Drama", 1999, "David Fincher"),
    ("Interstellar", "Sci-Fi", 2014, "Christopher Nolan"),
    ("The Green Mile", "Fantasy", 1999, "Frank Darabont"),
    ("Braveheart", "Action", 1995, "Mel Gibson"),
    ("Goodfellas", "Crime", 1990, "Martin Scorsese"),
    ("The Lord of the Rings: The Fellowship of the Ring", "Fantasy", 2001, "Peter Jackson"),
    ("Star Wars: Episode IV - A New Hope", "Sci-Fi", 1977, "George Lucas"),
    ("The Lord of the Rings: The Two Towers", "Fantasy", 2002, "Peter Jackson"),
    ("Jurassic Park", "Sci-Fi", 1993, "Steven Spielberg"),
    ("The Godfather: Part II", "Crime", 1974, "Francis Ford Coppola"),
    ("The Departed", "Crime", 2006, "Martin Scorsese"),
    ("Django Unchained", "Western", 2012, "Quentin Tarantino"),
    ("The Prestige", "Mystery", 2006, "Christopher Nolan"),
    ("The Usual Suspects", "Crime", 1995, "Bryan Singer"),
    ("Saving Private Ryan", "War", 1998, "Steven Spielberg"),
    ("American History X", "Drama", 1998, "Tony Kaye"),
    ("The Dark Knight Rises", "Action", 2012, "Christopher Nolan"),
    ("Inglourious Basterds", "War", 2009, "Quentin Tarantino"),
    ("Se7en", "Thriller", 1995, "David Fincher"),
    ("Whiplash", "Drama", 2014, "Damien Chazelle"),
    ("The Social Network", "Biography", 2010, "David Fincher"),
    ("Avengers: Endgame", "Action", 2019, "Anthony Russo and Joe Russo"),
    ("The Avengers", "Action", 2012, "Joss Whedon"),
    ("Shutter Island", "Thriller", 2010, "Martin Scorsese"),
    ("The Wolf of Wall Street", "Biography", 2013, "Martin Scorsese"),
    ("Mad Max: Fury Road", "Action", 2015, "George Miller"),
    ("Black Panther", "Action", 2018, "Ryan Coogler"),
    ("Wonder Woman", "Action", 2017, "Patty Jenkins"),
    ("Spider-Man: Into the Spider-Verse", "Animation", 2018, "Peter Ramsey, Rodney Rothman, and Bob Persichetti"),
    ("Coco", "Animation", 2017, "Lee Unkrich and Adrian Molina"),
    ("Frozen", "Animation", 2013, "Chris Buck and Jennifer Lee"),
    ("Moana", "Animation", 2016, "Ron Clements and John Musker"),
    ("Toy Story", "Animation", 1995, "John Lasseter"),
    ("Toy Story 3", "Animation", 2010, "Lee Unkrich"),
    ("Toy Story 4", "Animation", 2019, "Josh Cooley"),
    ("Finding Nemo", "Animation", 2003, "Andrew Stanton"),
    ("The Incredibles", "Animation", 2004, "Brad Bird"),
    ("Inside Out", "Animation", 2015, "Pete Docter"),
    ("Up", "Animation", 2009, "Pete Docter"),
    ("WALL·E", "Animation", 2008, "Andrew Stanton"),
    ("Ratatouille", "Animation", 2007, "Brad Bird"),
    ("Monsters, Inc.", "Animation", 2001, "Pete Docter"),
    ("A Bug's Life", "Animation", 1998, "John Lasseter"),
    ("Zootopia", "Animation", 2016, "Byron Howard and Rich Moore"),
    ("The Lego Movie", "Animation", 2014, "Phil Lord and Christopher Miller"),
    ("The Simpsons Movie", "Animation", 2007, "David Silverman"),
    ("Shrek", "Animation", 2001, "Andrew Adamson and Vicky Jenson"),
    ("Shrek 2", "Animation", 2004, "Andrew Adamson, Kelly Asbury, and Conrad Vernon"),
    ("Despicable Me", "Animation", 2010, "Pierre Coffin and Chris Renaud"),
    ("Despicable Me 2", "Animation", 2013, "Pierre Coffin and Chris Renaud"),
    ("Minions", "Animation", 2015, "Pierre Coffin and Kyle Balda"),
    ("How to Train Your Dragon", "Animation", 2010, "Dean DeBlois and Chris Sanders"),
    ("Kung Fu Panda", "Animation", 2008, "Mark Osborne and John Stevenson"),
    ("Kung Fu Panda 2", "Animation", 2011, "Jennifer Yuh Nelson"),
    ("Kung Fu Panda 3", "Animation", 2016, "Jennifer Yuh Nelson and Alessandro Carloni"),
    ("Madagascar", "Animation", 2005, "Eric Darnell and Tom McGrath"),
    ("Madagascar: Escape 2 Africa", "Animation", 2008, "Eric Darnell and Tom McGrath"),
    ("Madagascar 3: Europe’s Most Wanted", "Animation", 2012, "Eric Darnell, Tom McGrath, and Conrad Vernon"),
    ("Ice Age", "Animation", 2002, "Chris Wedge and Carlos Saldanha"),
    ("Ice Age: The Meltdown", "Animation", 2006, "Carlos Saldanha"),
    ("Ice Age: Dawn of the Dinosaurs", "Animation", 2009, "Carlos Saldanha and Mike Thurmeier"),
    ("Ice Age: Continental Drift", "Animation", 2012, "Steve Martino and Mike Thurmeier"),
    ("Ice Age: Collision Course", "Animation", 2016, "Mike Thurmeier and Galen T. Chu"),
    ("Hotel Transylvania", "Animation", 2012, "Genndy Tartakovsky"),
    ("Hotel Transylvania 2", "Animation", 2015, "Genndy Tartakovsky"),
    ("Hotel Transylvania 3: Summer Vacation", "Animation", 2018, "Genndy Tartakovsky"),
    ("The Secret Life of Pets", "Animation", 2016, "Chris Renaud and Yarrow Cheney"),
    ("The Secret Life of Pets 2", "Animation", 2019, "Chris Renaud"),
    ("Sing", "Animation", 2016, "Garth Jennings"),
    ("Sing 2", "Animation", 2021, "Garth Jennings"),
    ("Tangled", "Animation", 2010, "Nathan Greno and Byron Howard"),
    ("Big Hero 6", "Animation", 2014, "Don Hall and Chris Williams"),
    ("The Jungle Book", "Animation", 1967, "Wolfgang Reitherman"),
    ("The Little Mermaid", "Animation", 1989, "Ron Clements and John Musker"),
    ("Beauty and the Beast", "Animation", 1991, "Gary Trousdale and Kirk Wise"),
    ("Aladdin", "Animation", 1992, "Ron Clements and John Musker"),
    ("Mulan", "Animation", 1998, "Tony Bancroft and Barry Cook"),
    ("Pocahontas", "Animation", 1995, "Mike Gabriel and Eric Goldberg"),
    ("Hercules", "Animation", 1997, "Ron Clements and John Musker"),
    ("Tarzan", "Animation", 1999, "Kevin Lima and Chris Buck"),
    ("Atlantis: The Lost Empire", "Animation", 2001, "Gary Trousdale and Kirk Wise"),
    ("Lilo & Stitch", "Animation", 2002, "Chris Sanders and Dean DeBlois"),
    ("The Emperor's New Groove", "Animation", 2000, "Mark Dindal"),
    ("Treasure Planet", "Animation", 2002, "Ron Clements and John Musker"),
    ("Brother Bear", "Animation", 2003, "Aaron Blaise and Robert Walker"),
    ("Home on the Range", "Animation", 2004, "Will Finn and John Sanford"),
    ("Chicken Little", "Animation", 2005, "Mark Dindal"),
    ("Meet the Robinsons", "Animation", 2007, "Stephen Anderson"),
    ("Bolt", "Animation", 2008, "Chris Williams and Byron Howard"),
    ("The Princess and the Frog", "Animation", 2009, "Ron Clements and John Musker"),
    ("Winnie the Pooh", "Animation", 2011, "Stephen Anderson and Don Hall"),
    ("Frozen II", "Animation", 2019, "Chris Buck and Jennifer Lee"),
    ("Ralph Breaks the Internet", "Animation", 2018, "Phil Johnston and Rich Moore"),
    ("Wreck-It Ralph", "Animation", 2012, "Rich Moore"),
    ("Zootropolis", "Animation", 2016, "Byron Howard and Rich Moore")
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
now = datetime.now()
start_dates = [now - timedelta(days=random.randint(0, 7)) for _ in range(num_records)]


# Function to generate bell curve ratings centered around 3
def generate_bell_curve_rating(mu=3, sigma=0.5, min_val=1, max_val=5):
    while True:
        u1 = random.random()
        u2 = random.random()
        z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)
        rating = mu + z0 * sigma
        if min_val <= rating <= max_val:
            return round(rating, 1)

# Generate random ratings using bell curve
ratings = [generate_bell_curve_rating() for _ in range(num_records)]

# Create a CSV file
# with open('movie_streaming_data.csv', 'w', newline='') as file:
#     writer = csv.writer(file)
#     writer.writerow(['user_id', 'movie_name', 'streaming_hours', 'genre', 'gender', 'age', 'device', 'start_date', 'rating', 'year', 'director'])
#     for i in range(num_records):
#         writer.writerow([
#             user_ids[i], 
#             movie_choices[i][0], 
#             streaming_hours[i], 
#             movie_choices[i][1], 
#             user_genders[i], 
#             user_ages[i], 
#             streaming_devices[i], 
#             start_dates[i].strftime("%Y-%m-%d %H:%M:%S"), 
#             ratings[i],
#             movie_choices[i][2],
#             movie_choices[i][3]
#         ])
    
# print("Data generation complete. CSV file saved.")



def generate_random_record():
    user_id = random.randint(1, 1000000)
    movie_choice = random.choice(movies)
    streaming_hour = random.uniform(0.5, 10.0)
    gender = random.choice(['Male', 'Female', 'Other'])
    age = random.randint(10, 70)
    device = random.choice(['Smartphone', 'Tablet', 'Laptop', 'Desktop', 'Smart TV'])
    now = datetime.now()
    start_date = now - timedelta(days=random.randint(0, 7))
    rating = generate_bell_curve_rating()

    return {
        'user_id': user_id,
        'movie_name': movie_choice[0],
        'streaming_hours': streaming_hour,
        'genre': movie_choice[1],
        'gender': gender,
        'age': age,
        'device': device,
        'start_date': start_date.strftime("%Y-%m-%d %H:%M:%S"),
        'rating': rating,
        'year': movie_choice[2],
        'director': movie_choice[3]
    }

# Synchronous function to send data
def send_streaming_data_sync(data, api_url):
    response = requests.post(api_url, json=data)
    if response.status_code == 200:
        print("Data sent successfully (sync):", data)
    else:
        print("Failed to send data (sync):", response.text)

# Asynchronous function to send data
async def send_streaming_data_async(data, api_url):
    async with httpx.AsyncClient() as client:
        response = await client.post(api_url, json=data)
        if response.status_code == 200:
            print("Data sent successfully (async):", data)
        else:
            print("Failed to send data (async):", response.text)

# Example usage
if __name__ == "__main__":
    api_url = "http://example.com/api/streaming"  # Replace with your actual API endpoint
    data = generate_random_record()

    # Sending data synchronously
    # send_streaming_data_sync(data, api_url)

    # Sending data asynchronously
    import asyncio
    asyncio.run(send_streaming_data_async(data, api_url))