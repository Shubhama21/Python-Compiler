class Tool:
  def __init__(self, name_: str, ver_no_: int):
    self.name: str = name_
    self.version: int = ver_no_

  def print_details(self) -> None:
    print("Tool Details")
    print("Tool Name:")
    print(self.name)
    print("Version:")
    print(self.version)


class Lexer(Tool):
  def __init__(self, name_: str, ver_no_: int):
    Tool.__init__(self, name_, ver_no_)


class Parser(Tool):
  def __init__(self, name_: str, ver_no_: int):
    Tool.__init__(self, name_, ver_no_)


class Creators:
  def __init__(self, gp_no_: int, member_names_: list[str]):
    self.group_number: int = gp_no_
    self.member_names: list[str] = member_names_

  def print_details(self) -> None:
    n: int = len(self.member_names)
    print("Creator Details")
    print("Group Number:")
    print(self.group_number)
    print("Group Size:")
    print(n)
    print("Group Members:")
    i:int
    for i in range(n):
      print(self.member_names[i])


class Compiler:
  def __init__(self, ip_lang_: str, op_lang_: str, lexer_name_: str, lexer_version_: int, parser_name_: str, parser_version_: int, gp_no_: int, member_names_: list[str]):
    self.input_language: str = ip_lang_
    self.output_language: str = op_lang_
    self.lexer: Lexer = Lexer(lexer_name_, lexer_version_)
    self.parser: Parser = Parser(parser_name_, parser_version_)
    self.creators: Creators = Creators(gp_no_, member_names_)

  def print_details(self) -> None:
    print("Compiler Details")
    print("From Language:")
    print(self.input_language)
    print("To Language")
    print(self.output_language)
    print("Lexer:")
    self.lexer.print_details()
    print("Parser")
    self.parser.print_details()
    print("Creators")
    self.creators.print_details()


def main():
  obj: Compiler = Compiler("Python", "X86", "Flex", 2, "Bison", 3, 32, [
               "Harsh M", "Shubham A", "Shubham P"])
  obj.print_details()


if __name__ == "__main__":
  main()
