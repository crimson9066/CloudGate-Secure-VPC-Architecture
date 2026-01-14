import random
import sys
import time

MAX_TURNS = 6

characters = {
    "1": {
        "name": "Dutch",
        "style": "grandiose",
        "patience": 4
    },
    "2": {
        "name": "John",
        "style": "direct",
        "patience": 5
    },
    "3": {
        "name": "Arthur",
        "style": "reflective",
        "patience": 6
    }
}

concepts = {
    "VPC": "A Virtual Private Cloud is your private network inside AWS. It isolates your resources and gives you full control over IP ranges, subnets, routing, and security.",
    "Bastion": "A bastion host is a hardened server that acts as the only entry point into private subnets. You SSH into it, then reach internal systems.",
    "CIDR": "CIDR defines IP ranges. 10.0.0.0/16 means over 65,000 private IP addresses for your network.",
    "Subnets": "Subnets divide your VPC into public and private zones. Public subnets face the internet. Private ones stay hidden.",
    "NAT": "A NAT Gateway lets private instances reach the internet without exposing them to inbound traffic."
}

def slow(text):
    for c in text:
        print(c, end="", flush=True)
        time.sleep(0.015)
    print()

def death(name):
    slow(f"\n{name} sighs.")
    slow("This conversation has gone on long enough.")
    slow("A gunshot echoes. The world fades.")
    slow("\nGAME OVER\n")
    sys.exit()

def explain(style, topic):
    base = concepts[topic]
    if style == "grandiose":
        return f"My friend, {base} This is not merely architecture... this is destiny."
    if style == "direct":
        return f"{base} That’s all you need to know."
    if style == "reflective":
        return f"{base} Funny how everything works better when it’s built right."

def cdk_answer(style):
    if style == "grandiose":
        return "Soon. When the stars align and the repo demands evolution."
    if style == "direct":
        return "When Terraform is finished and tested."
    if style == "reflective":
        return "When the foundation is solid. No sense building fancy walls on weak ground."

def main():
    slow("\nYou approach a camp at dusk.\n")
    slow("Choose who you speak to:\n1. Dutch\n2. John\n3. Arthur\n")

    choice = input("> ").strip()
    if choice not in characters:
        slow("You wander off into the wilderness. Lost.")
        return

    char = characters[choice]
    name = char["name"]
    style = char["style"]
    patience = char["patience"]

    turns = 0

    slow(f"\n{name} looks at you.\n")

    while True:
        turns += 1
        if turns > patience:
            death(name)

        slow("\nWhat do you ask?\n")
        slow("1. Ask about cloud concepts")
        slow("2. Ask when CDK implementation is coming")
        slow("3. Leave politely\n")

        action = input("> ").strip()

        if action == "1":
            slow("\nChoose topic:")
            for i, k in enumerate(concepts.keys(), 1):
                slow(f"{i}. {k}")
            pick = input("> ").strip()
            keys = list(concepts.keys())
            if pick.isdigit() and 1 <= int(pick) <= len(keys):
                topic = keys[int(pick)-1]
                slow("\n" + explain(style, topic))
            else:
                slow("You mumble something unintelligible.")

        elif action == "2":
            slow("\n" + cdk_answer(style))

        elif action == "3":
            slow(f"\n{name} nods. You walk away alive.")
            return

        else:
            slow("That was... not an option.")

if __name__ == "__main__":
    main()
