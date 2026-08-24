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

#WorkflowStep: {
	label:       string & !=""
	description: string & !=""
	implements: [...string] & [_, ...]
}

#Workflow: {
	label: string & !=""
	steps: [...#WorkflowStep] & [_, ...]
}

#AcceptanceCriteria: {
	id:          string & =~"^AC-[A-Z]+-\\d{3}-\\d{2}$"
	description: string & !=""
}

#FunctionalRequirement: {
	id:      string & =~"^FR-[A-Z]+-\\d{3}$"
	title:   string & !=""
	persona: string & !=""
	acceptance_criteria: [...#AcceptanceCriteria] & [_, ...]
}

#NonFunctionalRequirement: {
	id:          string & =~"^NFR-[A-Z]+-\\d{3}$"
	title:       string & !=""
	description: string & !=""
}

#OpenQuestion: {
	question: string & !=""
	context?: string
}

#KPI: {
	metric: string & !=""
	target: string & !="" // qualitative acceptable in Draft
	baseline?: string
}

#Dependency: {
	description: string & !=""
	blocking:    bool | *false
	context?:    string
}

#State: {
	status:   "Draft" | "Review" | "Approved" | "Superseded"
	remarks?: string
}

#PRDDocument: {
	header: #PRDHeader
	slug?:  string & =~"^[a-z][a-z0-9-]*$"

	// Root-level fields
	stakeholders?: [...#Stakeholder] & [_, ...]
	title?:        string & !=""
	description?: string & !=""
	features?: [...string] & [_, ...]
	personas?: [...string] & [_, ...]
	scope?: {
		in_scope: [...string]
		out_of_scope: [...string]
	}
	nonfunctional_requirements?: [...#NonFunctionalRequirement] & [_, ...]
	kpis?: [...#KPI] & [_, ...]

	// Phase-level fields
	phase?:    string & !=""
	state?:    #State
	workflow?: #Workflow
	functional_requirements?: [...#FunctionalRequirement] & [_, ...]
	dependencies?: [...#Dependency] & [_, ...]

	open_questions?: [...#OpenQuestion]

	// A document is either a phase (has `phase`) or a parent (does not).
	// Each shape has its own required fields — `header` alone is not a
	// valid document either way.
	// Discriminate parent vs phase document shape: `!= _|_` means the
	// field is set (not bottom/undefined).
	if phase != _|_ {
		workflow:                 #Workflow
		functional_requirements: [...#FunctionalRequirement] & [_, ...]
	}
	if phase == _|_ {
		title:    string & !=""
		personas: [...string] & [_, ...]
	}
}
