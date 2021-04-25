#lang racket/base
(require "../../../medikanren2/common.rkt")

(define CHOP "HGNC:2726")

(define drug-categories '("biolink:ChemicalSubstance"
                          "biolink:ClinicalIntervention"
                          "biolink:ClinicalModifier"
                          "biolink:Drug"
                          "biolink:Treatment"))

(define inhibit-preds '("biolink:decreases_activity_of"
                        "biolink:decreases_expression_of"
                        "biolink:disrupts"
                        "biolink:negatively_regulates"
                        "biolink:negatively_regulates,_entity_to_entity"
                        "biolink:negatively_regulates,_process_to_process"
                        "biolink:treats"))

(define synonyms-preds '("biolink:same_as"
                         "biolink:close_match"
                         "biolink:has_gene_product"))

(define-relation (direct-synonym a b)
  (fresh (id sp)
    (edge id a b)
    (eprop id "predicate" sp)
    (membero sp synonyms-preds)))

(define-relation (direct-synonym+ a b)
  (conde ((direct-synonym a b))
         ((fresh (mid)
            (direct-synonym a mid)
            (direct-synonym+ mid b)))))

(define-relation (synonym a b)
  (conde ((direct-synonym a b))
         ((direct-synonym b a))
         ((fresh (mid)
            (direct-synonym a mid)
            (synonym mid b)))
         ((fresh (mid)
            (direct-synonym b mid)
            (synonym mid a)))))

(remove-duplicates (run*/steps 500 s (synonym "HGNC:2726" s))) 

(define CHOP-synonyms '("UMLS:C1413947"
  "PR:P35638"
  "UniProtKB:P0DPQ6"
  "UniProtKB:P35638"
  "ENSEMBL:ENSG00000175197"
  "NCBIGene:1649"
  "ORPHANET:321333"))


(define CHOP-drugs (time (run 300 (s sname p o pub prov)
                            (fresh (id drug)
                              (edge id s o)
                              (cprop s "category" drug)
                              (cprop s "name" sname)
                              (eprop id "predicate" p)
                              (eprop id "publications_info" pub)
                              (eprop id "provided_by" prov)
                              (membero o CHOP-synonyms)
                              (membero p inhibit-preds)
                              (membero drug drug-categories)))))



(display CHOP-drugs)