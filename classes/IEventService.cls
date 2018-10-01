public interface IEventService {
	void updateEventTeamHierachy(List<Event> eventList);
	void validateEditPermission(List<Event> eventList);
}