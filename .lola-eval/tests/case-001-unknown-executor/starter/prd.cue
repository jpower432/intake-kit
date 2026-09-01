package prds

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
	id:       string & =~"^[a-z][a-z0-9-]*$"
	label:    string & !=""
	"core-job": string & !=""
}

#DesiredOutcome: {
	id:           string & =~"^DO-[A-Z]+-\\d{3}$"
	statement:    string & !=""
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
	question: string & !=""
	context?: string
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

#PRDDocument: {
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
		title: string & !=""
		"job-executors": [...#JobExecutor] & [_, ...]
		"desired-outcomes"?: [...#DesiredOutcome]
	}
}
