export interface UserDTO {
  id: string
  email: string
  name?: string
}

export interface MessageDTO {
  id: string
  room: string
  fromId: string
  content: string
  createdAt: string
}
