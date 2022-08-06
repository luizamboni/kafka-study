
from uuid import uuid4
from faker import Faker
from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer
import argparse
import random
import hashlib


def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--registry')
  parser.add_argument('--topic')
  return parser.parse_args()

faker = Faker()
class ProductFaker:

    def __init__(self, names, brands) -> None:
        self.names = names
        self.brands = brands
        self.products = []

    def generate_product_name(self):
        first = faker.random_element(elements=(self.names))
        second = faker.random_element(elements=(self.brands))
        return f"{first} {second}"

    def generate_product_id(self, name):
        bytes_of_name = bytes(name, 'utf-8')
        m = hashlib.md5()
        m.update(bytes_of_name)
        return m.hexdigest()

    def get_random_product(self): 
        return random.choice(self.products)

    def generate(self): 
        name = self.generate_product_name()
        product_id = self.generate_product_id(name)

        product = {
            'name': name,
            'id': product_id
        }

        self.products = [product] + self.products

        return product

class VisitsFaker:
    def __init__(self) -> None:
        self.visits = []

    def generate(self):
        visit = {
            'id': str(uuid4())
        }
        self.visits.append(visit)
        return visit

class ClickFaker:

    def __init__(self) -> None:
        self.clicks = []

    def generate(self, product, visit):

        click = {
            'id': str(uuid4()),
            'product_id': product['id'],
            'visit_id': visit['id'],
        }

        self.clicks.append(click)
        return click


class OrdersFaker:

    def __init__(self) -> None:
        self.orders = []

    def generate(self, product, click):

        order = {
            'id': str(uuid4()),
            'product_id': product['id'],
            'click_id': click['id'],
        }

        self.orders.append(order)
        return order

visitFaker = VisitsFaker()
prodFaker = ProductFaker(
    ['A Phone', 'The Phone', 'Any Phone', 'Smart One'], 
    ['Xxx', 'Z-shell', 'BetterB', 'R']
)
clickFaker = ClickFaker()

orderFaker = OrdersFaker()


for i in range(100): 
    prodFaker.generate()

for i in range(100):

    visit = visitFaker.generate()
    click_prob = random.randint(0, 100)

    if click_prob > 70:
        product = prodFaker.get_random_product()
        click = clickFaker.generate(product, visit)

        product = prodFaker.get_random_product()
        click = clickFaker.generate(product, visit)


        order_prob = random.randint(0, 100)
        print("order_prob:", order_prob)

        if order_prob > 70:
            orderFaker.generate(product, click)
            orderFaker.generate(product, click)
            orderFaker.generate(product, click)

        elif order_prob > 60:
            orderFaker.generate(product, click)
            orderFaker.generate(product, click)

        elif order_prob > 50:
            orderFaker.generate(product, click)
            orderFaker.generate(product, click)

    elif click_prob > 50:
        product = prodFaker.get_random_product()
        click = clickFaker.generate(product, visit)

args = get_args()



def delivery_report(err, msg):
    if err is not None:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}]")

avroProducer = AvroProducer({
        'bootstrap.servers': args.host,
        'on_delivery': delivery_report,
        'schema.registry.url': args.registry
    },
)

for product in prodFaker.products:

    value_schema_str = """
    {
        "namespace": "product",
        "name": "value",
        "type": "record",
        "fields" : [
            { "name" : "name", "type" : "string" },
            { "name" : "id", "type" : "string" }
        ]
    }
    """


    value_schema = avro.loads(value_schema_str)
    key_schema = avro.loads('{"type": "string"}')

    avroProducer.produce(
        topic=f"{args.topic}-product", 
        value=product, 
        key=product['id'],
        key_schema=key_schema, 
        value_schema=value_schema
    )

    print(product)

for visit in visitFaker.visits:

    value_schema_str = """
    {
        "namespace": "product",
        "name": "value",
        "type": "record",
        "fields" : [
            { "name" : "id", "type" : "string" }
        ]
    }
    """


    value_schema = avro.loads(value_schema_str)
    key_schema = avro.loads('{"type": "string"}')

    avroProducer.produce(
        topic=f"{args.topic}-visit", 
        value=visit, 
        key=visit['id'],
        key_schema=key_schema, 
        value_schema=value_schema
    )

    print(visit)

for click in clickFaker.clicks:
    value_schema_str = """
    {
        "namespace": "product",
        "name": "value",
        "type": "record",
        "fields" : [
            { "name" : "id", "type" : "string" },
            { "name" : "product_id", "type" : "string" },
            { "name" : "visit_id", "type" : "string" }
        ]
    }
    """


    value_schema = avro.loads(value_schema_str)
    key_schema = avro.loads('{"type": "string"}')

    avroProducer.produce(
        topic=f"{args.topic}-click", 
        value=click, 
        key=click['id'],
        key_schema=key_schema, 
        value_schema=value_schema
    )


    print(click)

for order in orderFaker.orders:
    value_schema_str = """
    {
        "namespace": "product",
        "name": "value",
        "type": "record",
        "fields" : [
            { "name" : "id", "type" : "string" },
            { "name" : "product_id", "type" : "string" },
            { "name" : "click_id", "type" : "string" }
        ]
    }
    """


    value_schema = avro.loads(value_schema_str)
    key_schema = avro.loads('{"type": "string"}')

    avroProducer.produce(
        topic=f"{args.topic}-order", 
        value=order, 
        key=order['id'],
        key_schema=key_schema, 
        value_schema=value_schema
    )

    print(order)

avroProducer.flush()