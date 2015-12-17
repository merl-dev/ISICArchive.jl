type ListEntry
    id::ASCIIString
    name::ASCIIString
    updated::DateTime
end

function ListEntry(o::Dict)
    ListEntry(o["_id"], o["name"], parse_datetime(o["updated"]))
end

function Base.show(io::IO, o::ListEntry)
    print_with_color(:blue, io, o.name)
    print(io, ": id = $(o.id), updated = $(o.updated)")
end

# ==========================================================================

@defstruct DatasetListRequest (
    (limit::Int = 50, limit > 0),
    (offset::Int = 0, offset >= 0),
    sort::Symbol = :lowerName,
    (sortdir::Int = 1, sortdir == 1 || sortdir == -1)
)

function Base.get(req::DatasetListRequest)
    query = "https://isic-archive.com:443/api/v1/dataset?limit=$(req.limit)&offset=$(req.offset)&sort=$(req.sort)&sortdir=$(req.sortdir)"
    [ListEntry(o) for o in clean_json(get(query))]
end

# ==========================================================================

type DatasetMetadata
    accessLevel::Int
    id::ASCIIString
    modelType::ASCIIString
    created::DateTime
    creatorId::ASCIIString
    description::UTF8String
    name::ASCIIString
    updated::DateTime
end

function DatasetMetadata(o::Dict)
    DatasetMetadata(
        o["_accessLevel"],
        o["_id"],
        o["_modelType"],
        parse_datetime(o["created"]),
        o["creatorId"],
        o["description"],
        o["name"],
        parse_datetime(o["updated"]))
end

function Base.show(io::IO, o::DatasetMetadata)
    print_with_color(:white, io, string(typeof(o)), "\n")
    print(io,   "  .name: ")
    print_with_color(:blue, io, o.name, "\n")
    println(io, "  .id: ", o.id)
    println(io, "  .modelType: ", o.modelType)
    println(io, "  .creatorId: ", o.creatorId)
    println(io, "  .created: ", o.created)
    println(io, "  .updated: ", o.updated)
    println(io, "")
    print(io, o.description)
end

# ==========================================================================

@defstruct DatasetMetadataRequest (
    id::ASCIIString
)

DatasetMetadataRequest(le::ListEntry) = DatasetMetadataRequest(id = le.id)

function Base.get(req::DatasetMetadataRequest)
    query = "https://isic-archive.com:443/api/v1/dataset/$(req.id)"
    DatasetMetadata(clean_json(get(query)))
end
