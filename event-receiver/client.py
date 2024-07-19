from requests import request

for i in range(100_000):
    if i % 3 == 0:
        request("POST","http://localhost:5000", json={
            "name": "user_login",
            "version": "v1",
            "payload": {
                "name": "helena",
                "age": 30,
                "birth_date": "1995-12-12"
            }
        })
    elif i % 2 == 0:
        request("POST","http://localhost:5000", json={
            "name": "user_login",
            "version": "v2",
            "payload": {
                "name": "helena",
                "age": 30,
                "birth_date": "1995-12-12"
            }
        })
    else:
        request("POST","http://localhost:5000", json={
            "name": "user_login",
            "version": "v3",
            "payload": {
                "name": "helena",
                "age": 30,
                "birth_date": "1995-12-12"
            }
        })