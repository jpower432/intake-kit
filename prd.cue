package prds

import "strings"

#NonBlank: string & =~"\\S"

#SchemaVersion: =~"^[0-9]+\\.[0-9]+\\.[0-9]+$"
#Date:          =~"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"

#StakeholderRole: "Product Owner" | "Requestor" | "Stakeholder Representative" | "Technical Owner" | "Alternate Technical Owner"

#Stakeholder: {
	role:     #StakeholderRole
	handle:   string & !=""
	approver: bool | *false
}

#PRDHeader: {
	"schema-version": #SchemaVersion
	version:          #SchemaVersion
	"last-updated":   #Date
	parent?:          string & =~"^[a-z][a-z0-9-]*$"
}

#JourneyStep: {
	label:       string & !=""
	description: string & !=""
	implements: [...string] & [_, ...]
}

#Journey: {
	label:    string & !=""
	executor: string & !=""
	steps: [...#JourneyStep] & [_, ...]
}

#JobExecutor: {
	id:         string & =~"^[a-z][a-z0-9-]*$"
	label:      string & !=""
	"core-job": string & !=""
}

#DesiredOutcome: {
	id:            string & =~"^DO-[A-Z]+-\\d{3}$"
	statement:     string & !=""
	"executor-id": string & =~"^[a-z][a-z0-9-]*$"
}

#AcceptanceCriteria: {
	id:          string & =~"^AC-[A-Z]+-\\d{3}-\\d{2}$"
	description: string & !=""
}

#FunctionalRequirement: {
	id:    string & =~"^FR-[A-Z]+-\\d{3}$"
	title: string & !=""
	satisfies: [...string]
	"acceptance-criteria": [...#AcceptanceCriteria]
}

#NonFunctionalRequirement: {
	id:          string & =~"^NFR-[A-Z]+-\\d{3}$"
	title:       string & !=""
	description: string & !=""
	satisfies?: [...string]
}

#OpenQuestion: {
	question:  string & !=""
	context?:  string
	decision?: #Decision
}

#Decision: {
	id:     string & =~"^DEC-[A-Z]+-\\d{3}$"
	status: "Open" | "Resolved"
	blocks!: [...{
		phase:    =~"^[a-z][a-z0-9-]*$"
		activity: #NonBlank
	}]
	authority: {
		status:      "confirmed" | "unconfirmed"
		description: #NonBlank
	}
	resolution?: #NonBlank
	rationale?:  #NonBlank
	if status == "Resolved" {
		resolution: #NonBlank
		rationale:  #NonBlank
	}
	if status == "Open" {
		resolution?: error("resolution is only allowed on Resolved decisions")
		rationale?:  error("rationale is only allowed on Resolved decisions")
	}
}

#FeatureMapping: {
	feature: #NonBlank
	"fr-ids": [...=~"^FR-[A-Z]+-[0-9]{3}$"] & [_, ...]
	"allocation-status": "allocated" | "unconfirmed"
	evidence:            #NonBlank
}

#PhaseExitCriterion: {
	description: #NonBlank
	"requirement-ids"?: [...=~"^(FR|NFR)-[A-Z]+-[0-9]{3}$|^AC-[A-Z]+-[0-9]{3}-[0-9]{2}$"] & [_, ...]
}

#Dependency: {
	description: string & !=""
	blocking:    bool | *false
	context?:    string
}

#State: {
	status:   "Draft" | "Ready" | "Approved" | "Superseded"
	remarks?: string
}

#PRDDocument: D={
	header: #PRDHeader
	slug?:  string & =~"^[a-z][a-z0-9-]*$"

	stakeholders?: [...#Stakeholder] & [_, ...]
	title?:       string & !=""
	description?: string & !=""
	features?: [...string] & [_, ...]
	scope?: {
		"in-scope": [...string]
		"out-of-scope": [...string]
	}
	"nonfunctional-requirements"?: [...#NonFunctionalRequirement] & [_, ...]

	phase?: string & !=""
	state?: #State
	journeys?: [...#Journey] & [_, ...]
	"functional-requirements"?: [...#FunctionalRequirement] & [_, ...]
	dependencies?: [...#Dependency] & [_, ...]

	"open-questions"?: [...#OpenQuestion]
	"feature-mappings"?: [...#FeatureMapping] & [_, ...]
	lifecycle?: {diagram: #NonBlank, description: #NonBlank}
	"reading-guide"?: #NonBlank
	glossary?: [...{term: #NonBlank, definition: #NonBlank}] & [_, ...]
	"phase-exit-criteria"?: [...#PhaseExitCriterion] & [_, ...]

	// Validate local declarations; the Guard resolves inherited and family references.
	if D["feature-mappings"] != _|_ {
		if features != _|_ {
			_featureSet: {for feature in features {(feature): true}}
			_ck_mapping_feature: [for mapping in D["feature-mappings"] {_featureSet[mapping.feature] & true}]
		}
		if D["functional-requirements"] != _|_ {
			_mappingFRSet: {for f in D["functional-requirements"] {(f.id): true}}
			_ck_mapping_fr: [for mapping in D["feature-mappings"] for id in mapping["fr-ids"] {_mappingFRSet[id] & true}]
		}
	}

	if phase != _|_ {
		journeys: [...#Journey] & [_, ...]
		_fr="functional-requirements": [...#FunctionalRequirement] & [_, ...]

		// CUE-native FR/journey coverage floor: ORPHAN_FR (every FR is
		// implemented by at least one journey step) and UNKNOWN_FR (every
		// `implements` id names a real FR in this phase). A failure names
		// the offending id, e.g. `_ck_orphan_fr.1: undefined field: "FR-MFP-002"`.
		_frSet: {for f in _fr {(f.id): true}}
		_implementedFR: {for j in journeys for s in j.steps for id in s.implements {(id): true}}
		_ck_orphan_fr: [for f in _fr {_implementedFR[f.id] & true}]
		_ck_unknown_fr: [for j in journeys for s in j.steps for id in s.implements {_frSet[id] & true}]

		if D["phase-exit-criteria"] != _|_ {
			_exitRequirementSet: {
				for f in _fr {
					(f.id): true
					for ac in f["acceptance-criteria"] {(ac.id): true}
				}
			}
			// NFRs may be inherited from the parent and need the family review.
			_ck_exit_requirement: [for criterion in D["phase-exit-criteria"] if criterion["requirement-ids"] != _|_ {
				for id in criterion["requirement-ids"] if !strings.HasPrefix(id, "NFR-") {_exitRequirementSet[id] & true}
			}]
		}

		// Maturity gate: acceptance criteria are optional at early stage (Draft)
		// and required once a phase reaches Ready or Approved.
		if state != _|_ {
			if state.status == "Ready" || state.status == "Approved" {
				"functional-requirements": [...{"acceptance-criteria": [_, ...]}]
				"functional-requirements": [...{satisfies: [_, ...]}]
			}
		}
	}
	if phase == _|_ {
		"phase-exit-criteria"?: error("phase-exit-criteria is only allowed on phase PRDs")
		title:                  string & !=""
		"job-executors": [...#JobExecutor] & [_, ...]
		// Optional here by design: a Draft parent may not have matured
		// its outcomes yet. The prd-guard agent enforces the stricter
		// rule the schema can't see on its own — at least one non-empty
		// entry is required once any phase reaches Ready or Approved.
		"desired-outcomes"?: [...#DesiredOutcome]
	}
}
