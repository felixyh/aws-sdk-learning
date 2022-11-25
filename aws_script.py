import boto3

def dynamodb_fun():
    table = boto3.resource("dynamodb").Table("demotable")

    response = table.get_item(
        Key={
            "PK": "abc",
            "SK": "def"
        },
    )


def main():
    dynamodb_fun()

if __name__ == "__main__":
    main()