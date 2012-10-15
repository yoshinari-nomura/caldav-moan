class Category
  ##
  ## token
  ##
  token = {
    /[^!&|()\t \n]+/  => symbol,
    /!/               => negop,
    /&&/              => andop,
    /||/              => orop,
    "("               => lparen,
    ")"               => rparen
  }

  class Token
    
  end
  
  ##
  ## expression -> term ("||" term)*
  ##
  class Expression
  end

  ##
  ## term -> factor ("&&" factor)*
  ##
  class Term
  end

  ##
  ## factor -> "!"* category_name || "(" expression ")"
  ##
  class Factor
    
    
  end

end
