from faker import Faker

fake = Faker()

for i in range(1, 31):
    scheduleID = fake.random_int(min=1, max=50)
    starting_pointID = fake.random_int(min=1, max=10)
    end_pointID = fake.random_int(min=1, max=10)
    duration = fake.random_int(min=60, max=300)

    insert_statement = f"INSERT INTO route (scheduleID, starting_pointID, end_pointID, duration) VALUES ({scheduleID}, {starting_pointID}, {end_pointID}, {duration});"

    print(insert_statement)
