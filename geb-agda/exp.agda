{-# OPTIONS --with-K --exact-split --cumulativity #-}
 
open import Agda.Primitive using (Level; lzero; lsuc; _⊔_; Setω)

module exp where

  open import geb
  import HoTT
  open HoTT.Basics

  GF-obj : ObjGEBCat → (Type lzero)
  GF-obj Init = 𝟘
  GF-obj Term = 𝟙
  GF-obj (x ⊕G y) = (GF-obj x) + GF-obj y
  GF-obj (x ⊗G y) = (GF-obj x) × (GF-obj y)

  GF-mor : {x y : ObjGEBCat} → (x ↦ y) → ((GF-obj x) → (GF-obj y))
  GF-mor (f ● g) = GF-mor f ∘ GF-mor g
  GF-mor (IdMor _) = id _
  GF-mor (InitMor _) = λ { ()}
  GF-mor (TermMor _) = λ x₁ → pt
  GF-mor (CoProdMor f g) = [ (GF-mor f) , (GF-mor g) ]
  GF-mor (ProdMor f g) = < (GF-mor f) , (GF-mor g) >
  GF-mor DistribMor = proj₁ (×-hom-distrib-over-+ _ _ _)
  GF-mor inlG = inl
  GF-mor inrG = inr
  GF-mor p1G = pr₁
  GF-mor p2G = pr₂

  exp-fun : {x y : ObjGEBCat} → (GF-obj (InHom x y)) → ((GF-obj x) → (GF-obj y))
  exp-fun {Init} {y} pt ()
  exp-fun {Term} {y} = λ x x₁ → x
  exp-fun {x ⊕G y} {z} (f , g) (inl GFx) = (exp-fun f) GFx
  exp-fun {x ⊕G y} {z} (f , g) (inr GFy) = exp-fun g GFy
  exp-fun {x ⊗G y} {z} f (xx , yy) = exp-fun ((exp-fun f) xx) yy

  exp-fun-eq : {x y : ObjGEBCat} → is-an-equiv (exp-fun {x} {y})
  exp-fun-eq {Init} {y} = ((λ x → pt) ,, ( λ x → funext _ _ λ { ()}))
                                           ,
                          ( ((λ x → pt) ,, λ x → is-Contr-then-is-Prop 𝟙 𝟙-is-Contr _ _))
  exp-fun-eq {Term} {y} = (((λ f → f pt) ,, λ f → funext _ _ λ x → fun-ap f (is-Contr-then-is-Prop 𝟙 𝟙-is-Contr _ _))
                                       ,
                          ( (λ f → f pt) ,, λ f → refl _))
  exp-fun-eq {x ⊕G y} {z} = ((λ f → ((proj₁ (pr₁ (exp-fun-eq {x} {z}))) (λ x → f (inl x)))
                                     , (proj₁ (pr₁ (exp-fun-eq {y} {z}))) (λ y → f (inr y)))
                                                             ,, λ f → funext _ _ λ { (inl x) → transp (λ f' → (exp-fun (proj₁ (pr₁ exp-fun-eq) (λ x₂ → f (inl x₂)))) x ≡ (f' x))
                                                                                                      ((proj₂ (pr₁ (exp-fun-eq))) (λ x₂ → f (inl x₂))) (refl _) 
                                                                                   ; (inr y) → transp (λ f' → (exp-fun (proj₁ (pr₁ exp-fun-eq) (λ y₁ → f (inr y₁)))) y ≡ (f' y))
                                                                                                      ((proj₂ (pr₁ (exp-fun-eq))) (λ y₂ → f (inr y₂))) (refl _) })
                             ,
                             ((λ f → ((proj₁ (pr₁ (exp-fun-eq {x} {z}))) (λ x → f (inl x))) -- simplify this by pr₁ -> pr₂ hence avoiding transport
                                     , (proj₁ (pr₁ (exp-fun-eq {y} {z}))) (λ y → f (inr y)))
                                                            ,, λ { (f' , g') → prod-id-to-×-id _ _ 
                                                                                               (transp (λ (k : ((GF-obj x → GF-obj z) → (GF-obj (InHom x z)))) →
                                                                                                         k (λ x' → exp-fun f' x') ≡ f')
                                                                                                  ((qinverses-are-equal-with-funext (exp-fun {x} {z}) (exp-fun-eq {x} {z})) ⁻¹)
                                                                                                  ((proj₂ (pr₂ (exp-fun-eq {x} {z}))) f'))
                                                                                               ( (transp (λ (k : ((GF-obj y → GF-obj z) → (GF-obj (InHom y z)))) →
                                                                                                         k (λ y' → exp-fun g' y') ≡ g')
                                                                                                  ((qinverses-are-equal-with-funext (exp-fun {y} {z}) (exp-fun-eq {y} {z})) ⁻¹)
                                                                                                  ((proj₂ (pr₂ (exp-fun-eq {y} {z}))) g')))})
  exp-fun-eq {x ⊗G y} {z} = ((λ (f : (GF-obj x × GF-obj y → GF-obj z)) → (proj₁ (pr₁ (exp-fun-eq {x} {(InHom y z)})))
                                                                                                      ((proj₁ (pr₁ (exp-fun-eq {y} {z})))  ∘ (curry {lzero} {lzero} {lzero} f)))
                                        ,,  λ (f : (GF-obj x × GF-obj y → GF-obj z)) → funext _ _ λ {  (xx , yy) →
                                                                                                         {!!}})
                            ,
                            (((λ (f : (GF-obj x × GF-obj y → GF-obj z)) → (proj₁ (pr₂ (exp-fun-eq {x} {(InHom y z)})))
                                                                                                      ((proj₁ (pr₂ (exp-fun-eq {y} {z})))  ∘ (curry {lzero} {lzero} {lzero} f))))
                                                                                                      ,, (λ x₁ → {!!}))

  
{- exp-fun (exp-fun (proj₁ (pr₁ exp-fun-eq) (λ x₁ → proj₁ (pr₁ exp-fun-eq) (λ b → f (x₁ , b))))  xx)  yy
   ≡ f (xx , yy) -}
